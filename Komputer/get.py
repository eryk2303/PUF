import serial


ser = serial.Serial('/dev/ttyUSB0')
ser.baudrate(19200)
message = ser.read(256)
message = str(message, 'utf-8')
print(message)
ser.close()
