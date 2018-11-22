import math
import random

class rsa_core:
    def __init__(self):
        print("init")
        self.k_bits = 7
        self.maxNumber = math.pow(2, self.k_bits)

        #self.plainText  = random.randint(1, math.pow(2,self.k_bits))
        #self.plainText  = bin(self.plainText)format(7, '#010b')
        self.Message        = 19 #19
        self.bin_Message    = bin(self.Message)[2:].zfill(self.k_bits)
        #print("Msg",self.bin_Message)
        self.privateKey     = 77
        self.bin_privateKey = bin(self.privateKey)[2:].zfill(self.k_bits)
        self.publicKey      = 5
        self.bin_publicKey  = bin(self.publicKey)[2:].zfill(self.k_bits)
        #print("publickey", self.bin_publicKey)
        self.modulo         = 119
        self.bin_modulo     = bin(self.modulo)[2:].zfill(self.k_bits)
        #print("modulo", self.bin_modulo)

        self.r_mod_n        = 9
        self.r2_mod_n       = 81
        self.bin_r2_mod_n   = bin(self.r2_mod_n)[2:].zfill(self.k_bits)

        self.monPro_iter = 0
        
        
    def printAll(self):
        print("plain Text %s, %s\nprivateKey %s, %s \npublicKey %s, %s \nmodulo %s, %s" % (int(self.plainText,2), self.plainText, int(self.privateKey,2),self.privateKey, int(self.publicKey,2),self.publicKey, int(self.modulo,2),self.modulo))
        
    def print_LF(self):
        LF = math.pow(self.Message, self.publicKey)%self.modulo
        print("LF Cipher: ",LF)
        msg = self.decrypt(LF, self.privateKey)
        print("LF Msg: ", msg)

    def MonPro(self, A,B):
        self.monPro_iter = self.monPro_iter + 1
        u = 0
        #print(A)
        for i in range(self.k_bits):
            #print("bitnumber" ,self.k_bits-1-i," | ", A[self.k_bits-1-i])

            if (A[self.k_bits-1-i] == '1'):
                u = u + B
                #print("After u=u+b I: ", i , ", u=",hex(u))
            if u%2 != 0:
                u = u + self.modulo
                #print("After u=u+n I: ", i , ", u=",hex(u))
            u = u/2
            #print("After u/2, I: ", i , ", u=",hex(u))

        if u > self.modulo:
            print("WOW storre", u)
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

            #P = int(x_bar)
            P_bin = bin(P)[2:].zfill(self.k_bits)
            P = self.MonPro(P_bin, P)

        C_bin = bin(C)[2:].zfill(self.k_bits)
        final = self.MonPro(C_bin, 1)
       
        return final

    def ModExp(self):
        Message_bar = self.MonPro(self.bin_Message, self.r2_mod_n)
        print("Message_bar", Message_bar, hex(Message_bar))        
        bin_Message_bar = bin(int(Message_bar))[2:].zfill(self.k_bits)

        x_bar = self.r_mod_n
        #print("self.r_mod_n", self.r_mod_n)
        last_x = 0
        for i in range(self.k_bits):
            x_bar = int(x_bar)
            bin_x_bar = bin(x_bar)[2:].zfill(self.k_bits)
            x_bar = self.MonPro(bin_x_bar, x_bar)
            print(i, "x_bar:", x_bar, hex(x_bar))
            #if(last_x is not x_bar):
            #    print(i, "x_bar:", x_bar, hex(x_bar))
            last_x = x_bar
            if self.bin_publicKey[i] == '1':
                x_bar = self.MonPro(bin_Message_bar, x_bar)
                print(i, "x_bar key:", x_bar, hex(x_bar), Message_bar)

        x_bar = int(x_bar)
        last_x = bin(x_bar)[2:].zfill(self.k_bits)
        #print(last_x)
        ettall = bin(1)[2:].zfill(self.k_bits)
        #print("x iss: ", x_bar)
        x = self.MonPro(ettall, x_bar)
        return x
    
    def decrypt(self, cipher, key):
        key = bin(key)[2:].zfill(self.k_bits)
        r = math.pow(2,self.k_bits)

        cipher_bar = int((cipher*r)%self.modulo)
        bin_cipher_bar = bin(cipher_bar)[2:].zfill(self.k_bits)

        x_bar = int((1*r)%self.modulo)

        for i in range(self.k_bits):
            x_bar = int(x_bar)
            bin_x_bar = bin(x_bar)[2:].zfill(self.k_bits)
            x_bar = self.MonPro(bin_x_bar, x_bar)
            if key[i] == '1':
                x_bar = self.MonPro(bin_cipher_bar, x_bar)

        x_bar = int(x_bar)
        last_x = bin(x_bar)[2:].zfill(self.k_bits)
        x = self.MonPro(last_x, 1)
        return x



############################
###         MAIN         ###
############################
def main():
    rsa = rsa_core()
    bin_Message    = bin(19)[2:].zfill(8)
    A    = 118 #19
    A2   = bin(A)[2:].zfill(8)
    #print(A2, A)
    #cipher = rsa.MonPro(bin_Message,81)
   
    cipher = rsa.ModExp_Right_to_left()
    print("Cipher:", cipher, hex(cipher))

    #rsa.print_LF()
    #print("Antall ganger monPro kalt: ",rsa.monPro_iter)

main()