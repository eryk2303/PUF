import javax.swing.*;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.logging.Formatter;

public class uart_tx {

    JFrame frameTx;
    JButton send;
    JTextField message;
    JLabel messageInformation;
    String messageText;

    public uart_tx()
    {

        frameTx = new JFrame("TX");
        send = new JButton("send");
        message = new JTextField();
        messageInformation = new JLabel();

        frameTx.add(message);
        frameTx.add(messageInformation);
        message.setBounds(100,100, 200,30);
        messageInformation.setBounds(170, 50, 250, 30);


        message.setColumns(20);
        messageInformation.setText("Message");
        send.setBounds(140, 150, 100, 30);
        frameTx.add(send);
        send.addActionListener(e -> {
            if(message.getText() == null)
                messageText = "";
            else
                messageText = message.getText();

            //first.show();

        });
        frameTx.setSize(500, 500);
        frameTx.setLayout(null);
        frameTx.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frameTx.setVisible(true);
    }


    public static void main(String s[]) {
        new uart_tx();
    }

}