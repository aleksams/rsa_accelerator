import math
import random

class rsa_core:
    def __init__(self):
        
        if(0):
            self.Message        = int("0a2320202020202020202041307830203a464c20726f662065646f6320786548",16) 
            self.privateKey     = int("0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9", 16)
            self.publicKey      = int("0000000000000000000000000000000000000000000000000000000000010001", 16)
            self.hexModulo      = "99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
            self.modulo         = int("99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d", 16)
        else:
            self.Message        = int("0a46464645454545444444444343434342424242414141413030303039393939",16) 
            self.privateKey     = int("0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9", 16)
            self.publicKey      = int("0000000000000000000000000000000000000000000000000000000000010001", 16)
            self.hexModulo      = "99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d"
            self.modulo         = int("99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d", 16)
        
        self.R              = self.make_R()
        self.r_mod_n        = self.R%self.modulo
        self.r2_mod_n       = (self.R*self.R)%self.modulo

        self.bin_Message    = bin(self.Message)[2:].zfill(self.k_bits)
        print("Message:          ", hex(self.Message ))
        
        self.bin_privateKey = bin(self.privateKey)[2:].zfill(self.k_bits)
        self.bin_publicKey  = bin(self.publicKey)[2:].zfill(self.k_bits)
        self.bin_modulo     = bin(self.modulo)[2:].zfill(self.k_bits)
        self.bin_r2_mod_n   = bin(self.r2_mod_n)[2:].zfill(self.k_bits)
        
        self.monPro_iter = 0
        self.cipher = 0
    
    def make_R(self):
        self.modulo_msb_length = 3
        self.R_length       = (len(self.hexModulo)-1)*4 + self.modulo_msb_length + 1
        self.k_bits         = self.R_length
        self.R_bin          = "1" + "0"*(self.R_length)
        return int(self.R_bin, 2)
         
    def print_LF(self):
        LF = math.pow(self.Message, self.publicKey)%self.modulo
        print("LF Cipher: ",LF)
        msg = self.decrypt(LF, self.privateKey)
        print("LF Msg: ", msg)

    def MonPro(self, A,B):
        self.monPro_iter = self.monPro_iter + 1

        u = 0
        for i in range(self.k_bits):
            if (A[self.k_bits-1-i] == '1'):
                u = u + B
            if u%2 != 0:
                u = u + self.modulo
            u = u/2

        if u > self.modulo:
            u = u - self.modulo
        return u

    def ModExp_Right_to_left(self):
        C = self.r_mod_n
        C_bin = bin(int(C))[2:].zfill(self.k_bits)

        P = self.MonPro(self.bin_Message, self.r2_mod_n)
        P_bin = bin(int(P))[2:].zfill(self.k_bits)
        
        for i in range(self.k_bits):
            if self.bin_publicKey[self.k_bits-1-i] == '1':
                C_bin = bin(int(C))[2:].zfill(self.k_bits)
                C = self.MonPro(C_bin, P)

            P_bin = bin(P)[2:].zfill(self.k_bits)
            P = self.MonPro(P_bin, P)

        C_bin = bin(C)[2:].zfill(self.k_bits)
        self.cipher = self.MonPro(C_bin, 1)
        return self.cipher


def run():
    
    rsa = rsa_core()
    PlaintText = hex(rsa.Message)
    k_bits = rsa.k_bits

    cipher = rsa.ModExp_Right_to_left()
    
    rsa.Message = cipher
    rsa.bin_Message = bin(cipher)[2:].zfill(k_bits)
    rsa.publicKey = rsa.privateKey
    rsa.bin_publicKey = rsa.bin_privateKey
    RealText = rsa.ModExp_Right_to_left()

    print("Recovered Message:", hex(RealText))
    print("Cipher:", hex(cipher))
    Recovered_text = hex(RealText)

    if(PlaintText == Recovered_text):
        print("Correct")
    else:
        print("Wrong")
        print(PlaintText)
        print(textback)

    print("Antall ganger monPro kalt: ",rsa.monPro_iter)

############################
###         MAIN         ###
############################
def main():
    run()
    

main()

