# Google Summer of Code 2025



<center><a href=""><img src="https://developers.google.com/open-source/gsoc/resources/downloads/GSoC-logo-horizontal.svg" alt="gsoc" height="50" width="400"/> <img src="MERLLogo.png" height ="50" widht="400"/> </a></center> 


# AEGIS - AI-Enhanced Generation of Intelligent Scenarios

## Project Overview:

The Aegis project, part of Google Summer of Code 2025, is a versatile UVM (Universal Verification Methodology) testcase generator designed to automate the creation of verification testcases for any hardware Design Under Test (DUT). The tool accepts a user-provided JSON configuration file describing the DUT's interface (ports, data width) and testcase constraints, and generates SystemVerilog files for UVM components, including transaction, configuration, sequence, and test classes. These files facilitate functional verification of hardware designs in a UVM environment

## Objectives:


1. Universal DUT Support: Generate UVM testcase files for any DUT based on a JSON configuration.

2. Automate Verification: Produce UVM-compliant SystemVerilog files (<dut>_transaction.sv, <testcase>_config.sv, <testcase>_seq.sv, <dut>_test.sv) from user-defined JSON inputs.

3. Flexible Constraints: Allow users to specify constraints for input signals and additional fields (e.g., data ranges, boolean controls) in the JSON.

4. Debug and Scalability: Include robust error handling and debug output to ensure reliable file generation and easy extension for complex DUTs.

## Generated Files:


1. dut_transaction.sv: Defines the UVM transaction class with DUT input/output/inout ports and constraint fields (e.g., randomized inputs, non-randomized outputs).

2. testcase_config.sv: Defines configuration classes for each testcase, specifying constraints like min/max ranges for data and boolean controls.

3. testcase_seq.sv: Defines sequence classes to generate randomized transactions based on constraints, with debug logging for transaction details.

4. dut_test.sv: Defines the UVM test class to instantiate configurations and sequences, running them in a placeholder environment.

## Prerequisite:



1. Python 3.6+: Required to run the chta.py script.

2. Jinja2: Python library for template rendering (pip3 install jinja2).

3. UVM Simulator:

    EDA Playground: A cloud-based platform for running UVM simulations (https://www.edaplayground.com), I am using  Siemens Questa 2024.3 with UVM 1.2 support for compiling and simulating generated files.


### Developed by <b>Mahnoor Ismail</b> 



This Project was created as part of Google Summer of Code 2025 Programme for Open Source Contribution.


### How to Run

```ruby
python3 testcase_generator.py <json_file> <output_directory>