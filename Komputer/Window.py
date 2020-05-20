import wx
import os
import Communication


class MainWindow(wx.Frame):
    def __init__(self, parent, title):
        self.dirname=''

        wx.Frame.__init__(self, parent, title=title, size=(200,-1))
        self.control = wx.TextCtrl(self, style=wx.TE_MULTILINE)
        self.CreateStatusBar() 

        self.sizer2 = wx.BoxSizer(wx.HORIZONTAL)
        filemenu= wx.Menu()
        menuOpen = filemenu.Append(wx.ID_OPEN, "&Odwóż ","Odwóż")

        self.Bind(wx.EVT_MENU, self.OnOpen, menuOpen)

        self.send = wx.Button(self, -1, "Wyślij wiadomość")
        self.sizer2.Add(self.send, 1, wx.EXPAND)
        self.send.Bind(wx.EVT_BUTTON, self.buttonSend)

        self.reset = wx.Button(self, -1, "Zresetuj FPGA")
        self.sizer2.Add(self.reset, 1, wx.EXPAND)
        self.reset.Bind(wx.EVT_BUTTON, self.buttonReset)

        menuBar = wx.MenuBar()
        menuBar.Append(filemenu,"&Plik")

        self.message_Ctrl = wx.TextCtrl(self, style=wx.TE_MULTILINE)
        

        self.SetMenuBar(menuBar) 

        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self.control, 1, wx.EXPAND)
        self.sizer.Add(self.sizer2, 0, wx.EXPAND)
        self.sizer.Add(self.message_Ctrl, 1, wx.EXPAND)
        self.SetSizer(self.sizer)
        self.SetAutoLayout(1)
        self.sizer.Fit(self)
        self.Show()

        
    def OnExit(self,e):
        self.Close(True)

    def OnOpen(self,e):
        dlg = wx.FileDialog(self, "Choose a file", self.dirname, "", "*.*", wx.FD_OPEN)
        if dlg.ShowModal() == wx.ID_OK:
            self.filename = dlg.GetFilename()
            self.dirname = dlg.GetDirectory()
            f = open(os.path.join(self.dirname, self.filename), 'r')
            self.control.SetValue(f.read())
            f.close()
        dlg.Destroy()

    def buttonReset(self, event):
            Communication.reset()

    def buttonSend(self, event):
            message = Communication.send_message(str(self.control.GetValue()))
            self.message_Ctrl.SetValue(message)

app = wx.App(False)
frame = MainWindow(None, "SHA256")
app.MainLoop()



    