import javax.swing.*;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Scanner;

public class uart {

    JFrame frameTx;
    JButton send;
    JTextField message;
    JLabel messageInformation;
    String messageText;
    String sha;
    JLabel shaInformation;
    public uart()
    {

        frameTx = new JFrame("TX");
        send = new JButton("send");
        message = new JTextField();
        messageInformation = new JLabel();
        shaInformation = new JLabel();

        frameTx.add(shaInformation);
        frameTx.add(message);
        frameTx.add(messageInformation);
        message.setBounds(100,100, 200,30);
        messageInformation.setBounds(170, 50, 250, 30);
        shaInformation.setBounds(170, 200, 300, 50);
        shaInformation.setText("...");
        message.setColumns(20);
        messageInformation.setText("Message");
        send.setBounds(140, 150, 100, 30);
        frameTx.add(send);
        send.addActionListener(e -> {
            if(message.getText() == null)
                messageText = "";
            else
                messageText = message.getText();

            Runtime run = Runtime.getRuntime();
            try {
                Process pr = run.exec("sudo python send.py");
                System.out.println(messageText);
                Process pr3 = run.exec("sudo python get.py");
                Scanner fromProc = new Scanner(new InputStreamReader(pr.getInputStream()));
                while (fromProc.hasNextLine()) {
                    sha  = fromProc.nextLine();
                    shaInformation.setText(sha);
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }

        });
        frameTx.setSize(400, 500);
        frameTx.setLayout(null);
        frameTx.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frameTx.setVisible(true);
    }


    public static void main(String s[]) {
        new uart();
    }

}
