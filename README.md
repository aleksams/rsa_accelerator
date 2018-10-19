# rsa_accelerator
Design of RSA hardware accelerator

## Contents
* rsa_core: 

  Top module of the RSA accelerator, contains instantiations of the rsa_datapath and rsa_controller.
  
* rsa_datapath: 
  
  Complete datapath of the RSA accelerator, contains the registers for messages and ciphertext, as well as the memory mapped registers for key E, modulo N, R mod N etc. Contains instatiation of the modular_exponentiation module.
  
* rsa_controller: 

  Complete control logic for the RSA accelerator. Will contain counters and such.
  
* modular_exponentiation: 
  
  Module for computing the modular exponentiation to encrypt/decrypt messages. Contains instantiation of the modular_product and possibly shift_regs.
  
* modular_product: 

  Module for computing the modular product. Will contain instatiations of adders and shift_regs.
  
* shift_reg: 

  Shift register. Might split into shift_left_reg and shift_right_reg instead of on that does both.
