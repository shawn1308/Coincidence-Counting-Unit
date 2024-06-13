import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
import serial.tools.list_ports
import serial
import time
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar
import matplotlib.pyplot as plt
from datetime import datetime
import xlsxwriter

class Example(QWidget):
    def __init__(self):
        super().__init__()

        self.initUI()

    def initUI(self):
        main_vbox = QVBoxLayout(self)

# GAUCHE layout (COM port connection)------------------------------------------

        left = QVBoxLayout()
        left.addStretch()
        tit_conn = QLabel('Connection')
        tit_conn.setAlignment(Qt.AlignCenter)
        tit_conn.setFont(QFont('Times font', 15))
        tit_conn.setStyleSheet("color: Green") 
        left.addWidget(tit_conn)
        
        # Search COM avaible --------------------------
        self.ports = []
        for port in serial.tools.list_ports.comports():
            self.ports.append(port.name)
        # Selection COM--------------------------------
        txt_com_port = QLabel('PORT:')
        self.com_box = QComboBox()
        self.com_box.addItems(self.ports)
        
        com_hbox = QHBoxLayout()
        com_hbox.addWidget(txt_com_port)
        com_hbox.addWidget(self.com_box)
        
        #com_hbox.addStretch()
        #left.addStretch()
        left.addLayout(com_hbox,1)
        
        # selection Time-------------------------------
        txt_baud_port = QLabel('TIME:')
        self.baud_box = QComboBox() 
        self.baud_box.addItem("5 S")
        self.baud_box.addItem("10 S")
        
        baud_hbox = QHBoxLayout()
        baud_hbox.addWidget(txt_baud_port)
        baud_hbox.addWidget(self.baud_box)
        
        #baud_hbox.addStretch()
        #left.addStretch()
        left.addLayout(baud_hbox,1)
        # Button-------------------------------
        self.start_button = QPushButton('START')
        left.addWidget(self.start_button)
        self.start_button.clicked.connect(self.start_button_clicked)
        
        left.addStretch()
        
        # Chart-------------------------------------
        self.figure = plt.figure()
        self.canvas = FigureCanvas(self.figure)
        self.toolbar = NavigationToolbar(self.canvas, self)
        co_layout = QVBoxLayout()
        co_layout.addWidget(self.toolbar)
        co_layout.addWidget(self.canvas)
        self.setLayout(co_layout)
        
        #-------------------------------------------
        top_level_hbox = QHBoxLayout()
        top_level_hbox.addLayout(left,1)
        top_level_hbox.addLayout(co_layout,3)
        
#Bottom -----------------------------------------------------------------------
        # Chart-------------------------------------
        self.figure1 = plt.figure()
        self.canvas1 = FigureCanvas(self.figure1)
        self.toolbar1 = NavigationToolbar(self.canvas1, self)
        co_layout1 = QVBoxLayout()
        co_layout1.addWidget(self.toolbar1)
        co_layout1.addWidget(self.canvas1)
        self.setLayout(co_layout1)
        
#View--------------------------------------------------------------------------        
        main_vbox.addLayout(top_level_hbox,1)
        main_vbox.addLayout(co_layout1,1)

# Affichage -------------------------------------------------------------------
        self.setLayout(main_vbox)
        self.setGeometry(300, 75, 1400, 900)
        self.setWindowTitle('INTERFACE CCU')
        self.show()


# PLOT - Button Onclick() -------------------------------------------------------
    def start_button_clicked(self):
        Select_com = self.com_box.currentText()
        
        if self.baud_box.currentText() == '5 S':
            i_max = 5003
        else:
            i_max = 10003
        # Variable -------------------------------------
        self.figure1.clear()
        ax = self.figure1.add_subplot(111)
        
        self.figure.clear()
        ay = self.figure.add_subplot(111)
        
        self.data1 = []
        self.data2 = []
        self.CO1 = []
        self.CO2 = []
        self.time = []
        
        #Aquisition-------------------------------------
        s=serial.Serial(Select_com, 250000,timeout= 1)
        i = 0
        while i < i_max:
            s.write(b'S')
            data = s.read(10).hex()
            if data:
                fd,sd,C1,C2 = data[0:8], data[8:16],data[16:18],data[18:20]
                self.data1.append(int(fd,16))
                self.data2.append(int(sd,16))
                self.CO1.append(int(C1,16))
                self.CO2.append(int(C2,16))
                self.time.append(i)
            i = i+1
        s.write(b'F')
        s.write(b'R')
        s.close()
        
        #Processing COUNTER -----------------------------------
        d1 = []
        d2 = []
        for i in range(len(self.data1)):
            if i == 0:
                d1.append(self.data1[i])
                d2.append(self.data2[i])
            else:
                d1.append(self.data1[i] - self.data1[i-1])
                d2.append(self.data2[i] - self.data2[i-1])
        d1.pop(0)
        d2.pop(0)
        self.time.pop(len(self.time)-1)
        
        d1.pop(0)
        d2.pop(0)
        self.time.pop(len(self.time)-1)
        
        ax.plot(self.time,d1, 's')
        ax.plot(self.time,d2, 'o')
        self.canvas1.draw()
        #"print("DET 1")
        #print(d1)
        #print("DET 2")
        #print(d2)
        # Processing coincidence ---------------------------------
        count = []
        tline = []
        for i in range(50):
            count.append(self.CO1.count(i)+self.CO2.count(i))
            tline.append(i*3.33)
        
        ay.plot(tline,count)
        self.canvas.draw()
        # Write CSV ---------------------------------------------
        now = datetime.now()
        current_time = now.strftime("%H_%M_%S")
        workbook = xlsxwriter.Workbook(str(current_time) +'.csv')
        worksheet = workbook.add_worksheet("My sheet")
        row = 0
        col = 0
        for i in range(0,len(self.time)):
            worksheet.write(row, col, str(self.time[i]))
            worksheet.write(row, col+1, str(d1[i]))
            worksheet.write(row, col+2, str(d2[i]))
            row += 1
        
        row = 0
        col = 0
        for i in range(0,len(tline)):
            worksheet.write(row, col+3, str(tline[i]))
            worksheet.write(row, col+4, str(count[i]))
            row += 1
        # Clear -------------------------------------------------
        workbook.close()
        self.data1.clear()
        self.data2.clear()
        self.CO1.clear()
        self.CO2.clear()
        d1.clear()
        d2.clear()
        count.clear()
        self.time.clear()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())