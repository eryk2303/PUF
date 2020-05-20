import serial
import binascii

ser = serial.Serial('COM4')
ser.baudrate = 19200 

def send_message(message):
    message_tmp = []
    finish = 'FINIS000'
    finish = finish.encode("ascii")
    i = 0
    while len(message) >= (i+1)*64:
        message_tmp.append(message[i*64 : (i+1)*64])
        i = i + 1
    if len(message) != i*64:
        message_tmp.append(message[i*64 : len(message)])

    for ms in message_tmp:
        start = 'START' + str('{:03d}'.format(len(ms)*8))
        ms = ms.encode("utf-8")
        start = start.encode("ascii")
        ser.write(start)
        ser.write(ms)
    ser.write(finish)
    get = ser.read(32)
    
    return get
    

def reset():
    ser.write('RESET000'.encode("ascii"))


    

