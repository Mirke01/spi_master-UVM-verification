# spi_master-UVM-verification

Welcome to the spi_master UVM Verification repository. This project is dedicated to the functional verification of an SPI Master controller using the Universal Verification Methodology (UVM). The verification environment is meticulously designed to ensure the SPI Master operates correctly under various conditions and scenarios, guaranteeing its robustness and reliability.


This project is structured to provide a clear and organized verification environment:
1. UVC for SPI: Developed a Universal Verification Component (UVC) specifically for the SPI interface, handling all typical SPI operations and edge cases.

2. UVC for Wishbone: Created a UVC for the Wishbone interface, ensuring the accurate and efficient communication between the SPI Master and the Wishbone bus.

3. Integrated Verification Environment: Integrated the SPI and Wishbone UVCs to create a cohesive verification environment, enabling comprehensive testing of the SPI Master Design Under Test (DUT).

Repository Contents:

src/: Source code for the SPI Master controller and associated components.

tb/: Testbench files comprising UVM components for both SPI and Wishbone interfaces.

test_cases/: A comprehensive suite of test cases targeting various functionalities and edge cases.

scripts/: Utility scripts for compilation, simulation, and report generation.

docs/: Documentation detailing the setup, usage, and contribution guidelines for the verification environment.

