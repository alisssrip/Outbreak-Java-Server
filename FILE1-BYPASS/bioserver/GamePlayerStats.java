package bioserver;

public class GamePlayerStats {
    public static void logPlayerStats(Client client) {
        if(client == null) return;

        byte[] stats = client.getCharacterStats();
        System.out.println("=== ESTADÍSTICAS DEL JUGADOR ===");
        System.out.println("Usuario: " + client.getUserID());
        System.out.println("Handle: " + new String(client.getHNPair().getHandle()));
        System.out.println("Número: " + client.getPlayerNum());
        System.out.println("Área: " + client.getArea());
        System.out.println("Sala: " + client.getRoom());
        System.out.println("Slot: " + client.getSlot());
        System.out.println("Partida: " + client.gamenumber);
        System.out.println("Personaje: " + client.getCharacter());
        System.out.println("Disfraz: " + client.getCostume());

        // Mostrar primeros 16 bytes (probablemente vida, infección, posición)
        System.out.print("Datos crudos: ");
        for(int i = 0; i < Math.min(16, stats.length); i++) {
            System.out.print(String.format("%02X ", stats[i] & 0xFF));
        }
        System.out.println();
    }
}
