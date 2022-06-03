import cv2

Height= 31
Width = 32
image = cv2.imread('./image.jpg')                 # 相對路徑
image = cv2.cvtColor(image , cv2.COLOR_BGR2GRAY)  # 以黑白圖像讀取
image = cv2.resize(image, ( Width , Height ))     # 變更大小

file_in  =  open("img.dat",mode = "w")   
file_out = open("golden.dat",mode = "w")  

print('Start writung img.dat')
for i in range (0,Height):
    for j in range(0,Width) :
        number =  hex(image[i][j]) 
        if(i%2 == 0):
            print(i*16+j+1 ,number[2:4])
            file_in.write(number[2:4] + '\n')
print('End of writing img.dat')
print('----------------------')
print('----------------------')
print('Start writing golden.dat')
for i in range (0,Height):
    for j in range(0,Width) : 
        if(i%2 == 1):
            if(j == 0 or j == Width-1):
                image[i][j] = (int(image[i-1][j]) + int(image[i+1][j]))/2                   
            else :
                a = int(image[i-1][j-1])
                b = int(image[i-1][j  ])
                c = int(image[i-1][j+1])
                d = int(image[i+1][j-1])
                e = int(image[i+1][j  ])
                f = int(image[i+1][j+1])
                D1 = abs(a - f) 
                D2 = abs(b - e) 
                D3 = abs(c - d)                   
                if(D2 <= D3 and D2 <= D1):
                    image[i][j] = (b + e)/2  
                elif(D1 <= D3):
                    image[i][j] = (a + f)/2 
                else : 
                    image[i][j] = (c + d)/2                          
        number = hex (image[i][j])  
        print(i*32+j+1 ,number[2:4]) 
        file_out.write(number[2:4] + '\n')
print('End of writing golden.dat')

file_in.close()
file_out.close()