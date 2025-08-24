import json
import sys
import os
from jinja2 import Template


def parse_json(json_path):
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading JSON file: {e}")
        sys.exit(1)

    dut = data.get('dut', 'generic_dut').lower()
    data_width = int(data.get('data_width', 32))

    ports = data.get('ports', [])
    if not ports:
        print("Error: No ports found in JSON")
        sys.exit(1)

    testcases = data.get('testcases', []) or data.get('tests', [])
    if not testcases:
        print("Error: No testcases found in JSON")
        sys.exit(1)


    constrained_fields = set()
    bool_constraint_names = set()

    for tc in testcases:
        constraints = tc.get('constraints', {}) or {}
        for key in constraints:
            if key.endswith('_min') or key.endswith('_max'):
                base = key.rsplit('_', 1)[0]
                constrained_fields.add(base)
            
            if key.startswith('enable_') or key.startswith('flag_'):
                bool_constraint_names.add(key)

    port_names = {p['name'] for p in ports}
    input_port_names = {
        p['name'] for p in ports if p.get('direction', 'input') == 'input'
    }

   
    fields_all = sorted(list(constrained_fields))
    bool_names_all = sorted(list(bool_constraint_names))

    parsed_testcases = []
    for tc in testcases:
        name_raw = tc.get('name') or f"test_{len(parsed_testcases)+1}"
        name = name_raw.lower().replace(' ', '_')
        num_transactions = int(tc.get('num_transactions', 10))
        constraints = tc.get('constraints', {}) or {}

        
        field_constraints = {}
        for f in fields_all:
           
            min_c = constraints.get(f"{f}_min", {"value": 0, "datatype": "int"})
            max_c = constraints.get(f"{f}_max", {"value": (1 << data_width) - 1, "datatype": "int"})

            min_val = min_c["value"] if isinstance(min_c, dict) else min_c
            max_val = max_c["value"] if isinstance(max_c, dict) else max_c
            dt = (min_c.get("datatype", "int") if isinstance(min_c, dict) else "int")

            field_constraints[f] = {
                "min": min_val,
                "max": max_val,
                "datatype": dt
            }

        
        bools = {}
        for b in bool_names_all:
            v = constraints.get(b, {"value": False, "datatype": "bit"})
            if isinstance(v, dict):
                val = bool(v.get("value", False))
                dt = v.get("datatype", "bit")
            else:
                val = bool(v)
                dt = "bit"
            bools[b] = {"value": val, "datatype": dt}

        parsed_testcases.append({
            "name": name,
            "num_transactions": num_transactions,
            "data_width": data_width,
            "field_constraints": field_constraints,
            "bool_constraints": bools
        })

    print(f"Parsed JSON: DUT={dut}, ports={len(ports)}, "
          f"fields={fields_all}, bools={bool_names_all}")

    return dut, data_width, ports, input_port_names, fields_all, bool_names_all, parsed_testcases


# ---------------------
# Templates
# ---------------------
transaction_template = Template(r"""
`include "uvm_macros.svh"
import uvm_pkg::*;

class {{dut}}_transaction extends uvm_sequence_item;

  // Port-backed fields
{% for p in ports %}
{%   if p.name not in ['clk','clock','rst','reset','reset_n','rstn'] %}
{%     if p.direction == 'input' %}
  rand logic{% if p.size|int > 1 %} [{{p.size-1}}:0]{% endif %} {{p.name}};
{%     else %}
  logic{% if p.size|int > 1 %} [{{p.size-1}}:0]{% endif %} {{p.name}};
{%     endif %}
{%   endif %}
{% endfor %}

  // Extra non-port constrained fields
{% for f in extra_fields %}
  rand int {{f}};
{% endfor %}

  // Boolean knobs
{% for b in bool_names %}
  rand bit {{b}};
{% endfor %}

  `uvm_object_utils({{dut}}_transaction)

  function new(string name = "{{dut}}_transaction");
    super.new(name);
  endfunction
endclass
""")

config_template = Template(r"""
`include "uvm_macros.svh"
import uvm_pkg::*;

class {{config_name}} extends uvm_object;
  // data_width kept for convenience
  rand int data_width = {{data_width}};

  // Ranged fields (both port-backed and extras)
{% for f,cons in field_constraints.items() %}
  rand {{cons.datatype}} {{f}}_min = {{cons.min}};
  rand {{cons.datatype}} {{f}}_max = {{cons.max}};
{% endfor %}

  // Boolean fields
{% for b,bc in bool_constraints.items() %}
  rand {{bc.datatype}} {{b}} = {{ "1'b1" if bc.value else "1'b0" }};
{% endfor %}

  `uvm_object_utils({{config_name}})
  function new(string name = "{{config_name}}");
    super.new(name);
  endfunction
endclass
""")

sequence_template = Template(r"""
`include "uvm_macros.svh"
import uvm_pkg::*;

class {{seq_name}} extends uvm_sequence#({{dut}}_transaction);
  {{config_name}} cfg;
  `uvm_object_utils({{seq_name}})

  function new(string name = "{{seq_name}}");
    super.new(name);
  endfunction

  task body();
    {{dut}}_transaction tx;

    // Get config from the sequencer scope
    if (!uvm_config_db#({{config_name}})::get(m_sequencer, "", "{{config_name}}", cfg))
      `uvm_fatal("NO_CFG", "Config not found for {{seq_name}}")

    if (starting_phase != null) starting_phase.raise_objection(this);
    repeat ({{num_transactions}}) begin
      tx = {{dut}}_transaction::type_id::create("tx");
      start_item(tx);
      if (!tx.randomize() with {
        // Apply ranges to ALL constrained fields (including input ports)
{% for f in all_fields %}
        tx.{{f}} inside { [ cfg.{{f}}_min : cfg.{{f}}_max ] };
{% endfor %}
        // Apply boolean knobs
{% for b in bool_names %}
        tx.{{b}} == cfg.{{b}};
{% endfor %}
      }) begin
        `uvm_error("RAND_FAIL","Randomization failed in {{seq_name}}")
      end
      finish_item(tx);
    end
    if (starting_phase != null) starting_phase.drop_objection(this);
  endtask
endclass
""")

test_template = Template(r"""
`include "uvm_macros.svh"
import uvm_pkg::*;

class {{dut}}_test extends uvm_test;
  `uvm_component_utils({{dut}}_test)

  {{dut}}_env env;

{% for tc in testcases %}
  {{tc.name}}_config {{tc.name}}_cfg_h;
{% endfor %}

  function new(string name = "{{dut}}_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = {{dut}}_env::type_id::create("env", this);

    // Create and scope config(s) to the sequencer
{% for tc in testcases %}
    {{tc.name}}_cfg_h = {{tc.name}}_config::type_id::create("{{tc.name}}_cfg_h");
    uvm_config_db#({{tc.name}}_config)::set(this, "env.agent.sequencer", "{{tc.name}}_config", {{tc.name}}_cfg_h);
{% endfor %}
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Start all sequences on the real sequencer
{% for tc in testcases %}
    {{tc.name}}_seq::type_id::create("{{tc.name}}_seq_h").start(env.agent.sequencer);
{% endfor %}

    phase.drop_objection(this);
  endtask
endclass
""")


# ---------------------
# Generator
# ---------------------
def generate_files(json_path, output_dir="output_uvm"):
    dut, data_width, ports, input_port_names, fields_all, bool_names_all, testcases = parse_json(json_path)
    os.makedirs(output_dir, exist_ok=True)

    # Normalize ports into simple objects for the templates
    class _P: pass
    port_objs = []
    for p in ports:
        po = _P()
        po.name = p.get('name')
        po.direction = p.get('direction', 'input')
        po.size = int(p.get('size', 1))
        po.datatype = p.get('datatype', 'logic')  
        port_objs.append(po)

    
    extra_fields = [f for f in fields_all if f not in input_port_names]

    # ----------------- Transaction -----------------
    trans_code = transaction_template.render(
        dut=dut,
        ports=port_objs,
        extra_fields=extra_fields,
        bool_names=bool_names_all
    )
    with open(os.path.join(output_dir, f"{dut}_transaction.sv"), "w") as f:
        f.write(trans_code)

    # ------------- Config + Sequence per testcase -------------
    for tc in testcases:
        config_name = f"{tc['name']}_config"
        seq_name = f"{tc['name']}_seq"

        cfg_code = config_template.render(
            config_name=config_name,
            data_width=tc['data_width'],
            field_constraints=tc['field_constraints'],   
            bool_constraints=tc['bool_constraints']
        )
        with open(os.path.join(output_dir, f"{config_name}.sv"), "w") as f:
            f.write(cfg_code)

        seq_code = sequence_template.render(
            seq_name=seq_name,
            config_name=config_name,
            dut=dut,
            num_transactions=tc['num_transactions'],
            all_fields=fields_all,          
            bool_names=bool_names_all
        )
        with open(os.path.join(output_dir, f"{seq_name}.sv"), "w") as f:
            f.write(seq_code)

    # ----------------- Test -----------------
    test_code = test_template.render(dut=dut, testcases=testcases)
    with open(os.path.join(output_dir, f"{dut}_test.sv"), "w") as f:
        f.write(test_code)

    print(f"Generated UVM files for '{dut}' in '{output_dir}'")
    print("Files created:")
    for fn in sorted(os.listdir(output_dir)):
        print("  ", fn)


# ---------------------
# Main
# ---------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 generate_uvm.py <json_path> [output_dir]")
        sys.exit(1)
    json_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "output_uvm"
    generate_files(json_path, output_dir)
