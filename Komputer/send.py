import serial



message = str(input())
print(message)
message = message.encode("utf-8")
ser = serial.Serial('/dev/ttyUSB0')
ser.baudrate(19200)
ser.write(message)
ser.close()
