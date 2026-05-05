package bioserver;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Date;

public class ServerMainSlim {

    public final static int GAMEPORT = 8690;

    private static final boolean SELFHOST_MODE = !"false".equalsIgnoreCase(System.getenv("BYPASS_SELFHOST"));

    public static void main(String[] args) {
        System.out.println("------------------------------\n" +
                "-        BHOF1-Host          -\n" +
                "-  GameServer :" + GAMEPORT + "         -\n" +
                "-                            -\n" +
                "- Based on BioServer         -\n" +
                "- (c) 2013-2019 obsrv.org    -\n" +
                "- (c) 2026 Makii             -\n" +
                "------------------------------\n");

        if(SELFHOST_MODE) {
            String sessid = System.getenv("BYPASS_SESSID");
            String publicIp = System.getenv("BYPASS_PUBLIC_IP");
            String region = System.getenv("BYPASS_REGION");

            if(sessid == null || sessid.isBlank()) {
                System.err.println("missing BYPASS_SESSID env var");
                System.exit(1);
            }
            if(publicIp == null || publicIp.isBlank()) {
                publicIp = detectPublicIp();
                if(publicIp == null) {
                    System.err.println("could not detect public IP, set BYPASS_PUBLIC_IP env var");
                    System.exit(1);
                }
                System.out.println("detected public IP " + publicIp);
            }

            Database tempDb = new Database();
            if(!tempDb.registerGameServer(sessid, publicIp, GAMEPORT, region)) {
                System.err.println("register failed, aborting");
                System.exit(1);
            }
            System.out.println("registered with Yoko as " + publicIp + ":" + GAMEPORT);

            final String finalSessid = sessid;
            Thread heartbeat = new Thread(() -> {
                while(!Thread.currentThread().isInterrupted()) {
                    try {
                        Thread.sleep(30000);
                        tempDb.heartbeatGameServer(finalSessid);
                    } catch (InterruptedException e) {
                        return;
                    }
                }
            }, "yoko-heartbeat");
            heartbeat.setDaemon(true);
            heartbeat.start();

            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                System.out.println("unregistering from Yoko");
                tempDb.unregisterGameServer(finalSessid);
            }, "yoko-unregister"));
        }

        GameServerPacketHandler packethandler = new GameServerPacketHandler();
        new Thread(packethandler).start();

        GameServerThread gsserver = new GameServerThread(null, GAMEPORT, packethandler);
        new Thread(gsserver).start();

        new Thread(new HeartBeatThreadSlim(gsserver, packethandler)).start();

        Date date = new Date();
        System.out.println(date + " bypass started on port " + GAMEPORT);
    }

    private static String detectPublicIp() {
        try {
            HttpClient c = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.ipify.org"))
                    .timeout(Duration.ofSeconds(5))
                    .GET()
                    .build();
            HttpResponse<String> r = c.send(req, HttpResponse.BodyHandlers.ofString());
            if(r.statusCode() == 200) return r.body().trim();
        } catch (Exception ex) {
            return null;
        }
        return null;
    }
}