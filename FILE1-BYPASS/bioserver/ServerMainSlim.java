/*
    BHOF1-Host - Selfhost GameServer for
                 Biohazard Outbreak File #1 (Playstation 2)

    Based on BioServer by obsrv.org
    Copyright (C) 2013-2019 obsrv.org (no23@deathless.net)
    Modified (C) 2026 OutbreakHub

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package bioserver;

import com.dosse.upnp.UPnP;

import java.io.IOException;
import java.net.InetAddress;
import java.util.Date;
import java.util.Map;

import org.bitlet.weupnp.GatewayDevice;
import org.bitlet.weupnp.GatewayDiscover;
import org.bitlet.weupnp.PortMappingEntry;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;

/**
 * BHOF1-Host entry point
 * Starts only the GameServer (port 25565), no Lobby.
 * Players log in through the central server and get
 * redirected here for the actual game session.
 */
public class ServerMainSlim {

    public final static int GAMEPORT = 8690;
    public static void main(String[] args) {
        GatewayDiscover discover = new GatewayDiscover();
        /*
        discover.setTimeout(10000);
        Map<InetAddress, GatewayDevice> gateways = null;
        try {
            gateways = discover.discover();
        } catch (IOException e) {
            throw new RuntimeException(e);
        } catch (SAXException e) {
            throw new RuntimeException(e);
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }

        if (gateways.isEmpty()) {
            System.out.println("No se encontró gateway UPnP");
        } else {
            GatewayDevice gateway = discover.getValidGateway();
            if (gateway != null) {
                PortMappingEntry portMapping = new PortMappingEntry();
                try {
                    if (gateway.addPortMapping(GAMEPORT, GAMEPORT,
                            gateway.getLocalAddress().getHostAddress(),
                            "TCP", "MyGame")) {
                        System.out.println("Puerto abierto correctamente");
                    }
                } catch (IOException e) {
                    throw new RuntimeException(e);
                } catch (SAXException e) {
                    throw new RuntimeException(e);
                }
            }

        }
*/
        System.out.println("------------------------------\n" +
                           "-        BHOF1-Host           -\n" +
                           "-  Selfhost GameServer :8690  -\n" +
                           "-                             -\n" +
                           "- Based on BioServer          -\n" +
                           "- (c) 2013-2019 obsrv.org     -\n" +
                           "- (c) 2026 Makii              -\n" +
                           "------------------------------\n");

        // Solo el GameServer, sin Lobby
        GameServerPacketHandler packethandler2 = new GameServerPacketHandler();
        new Thread(packethandler2).start();

        GameServerThread gsserver = new GameServerThread(null, GAMEPORT, packethandler2);
        new Thread(gsserver).start();

        // HeartBeat solo para el GameServer
        new Thread(new HeartBeatThreadSlim(gsserver, packethandler2)).start();

        Date date = new Date();
        System.out.println(date.toString() + " BHOF1-Host started on port " + GAMEPORT);
    }
}
