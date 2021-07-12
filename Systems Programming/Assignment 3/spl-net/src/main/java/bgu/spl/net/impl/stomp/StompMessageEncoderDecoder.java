package bgu.spl.net.impl.stomp;

import bgu.spl.net.api.MessageEncoderDecoder;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

public class StompMessageEncoderDecoder implements MessageEncoderDecoder {


    private Frame frame = new Frame();
    private byte[] bytes = new byte[1 << 10];
    private boolean firstLine = true;
    private boolean downLineBefore = false;
    private boolean alreadyBody = false;
    private int len = 0;

    @Override
    public Object decodeNextByte(byte nextByte) {

        if (nextByte == '\u0000') {
            frame.setBody(popString());
            Frame outputFrame = new Frame(frame);
            clear();
            return outputFrame;
        }

        if (nextByte == '\n'){

            if (downLineBefore){
                alreadyBody=true;
                return null;
            }

            if (firstLine){
                frame.setCommand(popString());
                firstLine = false;
            }
            else{
                if (alreadyBody){
                    pushByte(nextByte);
                }
                else{
                    String temp = popString();
                    String key = temp.substring(0,temp.indexOf(':'));
                    String value = temp.substring(temp.indexOf(':')+1);
                    frame.addHeader(key, value);
                }
            }
            downLineBefore = true;
        }
        else{
            downLineBefore = false;
            pushByte(nextByte);
        }
        return null;

    }

    @Override
    public byte[] encode(Object message) {
        return message.toString().getBytes();
    }

    private void pushByte(byte nextByte) {
        if (len >= bytes.length) {
            bytes = Arrays.copyOf(bytes, len * 2);
        }

        bytes[len++] = nextByte;
    }

    private String popString() {
        //notice that we explicitly requesting that the string will be decoded from UTF-8
        //this is not actually required as it is the default encoding in java.
        String result = new String(bytes, 0, len, StandardCharsets.UTF_8);
        len = 0;
        return result;
    }

    private void clear(){
        frame.clear();
        firstLine=true;
        downLineBefore=false;
        alreadyBody=false;
    }
}

