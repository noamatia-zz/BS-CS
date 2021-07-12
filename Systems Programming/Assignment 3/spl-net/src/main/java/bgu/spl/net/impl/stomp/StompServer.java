package bgu.spl.net.impl.stomp;

import bgu.spl.net.api.MessageEncoderDecoder;
import bgu.spl.net.api.StompMessagingProtocol;
import bgu.spl.net.srv.ConnectionsImpl;
import bgu.spl.net.srv.Server;
import java.util.function.Supplier;

public class StompServer {
    public static void main(String[] args) {
        if (args[1].equals("tpc")) {
            Server.threadPerClient(Integer.parseInt(args[0]),
            StompMessagingProtocolImpl::new,
            StompMessageEncoderDecoder::new).serve();
        }
        if (args[1].equals("reactor")) {
            Server.reactor(Runtime.getRuntime().availableProcessors(),
                    Integer.parseInt(args[0]),
                    StompMessagingProtocolImpl::new,
                    StompMessageEncoderDecoder::new)
                    .serve();
        }

    }
}
