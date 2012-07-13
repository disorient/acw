//package info.disorient.acw;
//import processing.core.PApplet;

import hypermedia.net.UDP;

import java.util.ConcurrentModificationException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

public class AndroidListener extends Routine {

	private UDP udpListener;
	private int udp_port;
	private Map<Integer, Integer> map;
	private boolean isDrawing;
	private Iterator it;
	private Set s;

	public AndroidListener(int port) {
		// TODO Auto-generated constructor stub

		udp_port = port;
	}

	public void setup(PApplet p) {
		this.parent = p;
		udpListener = new UDP(this, udp_port);
		udpListener.listen(true);

		map = new HashMap<Integer, Integer>();

		parent.background(0);

		// adding or set elements in Map by put method key and value pair

	}

	public void draw() {
		// Get Map in Set interface to get key and value
		s = map.entrySet();

		// Move next key and value of Map by iterator
		it = s.iterator();

		if (it.hasNext()) {
			isDrawing = true;
			parent.loadPixels();
			parent.background(0);
		}

		boolean doLoop = it.hasNext();

		while (doLoop) {
			// key=value separator this by Map.Entry to get key and value

			try {
				Map.Entry m = (Map.Entry) it.next();
				int key = (Integer) m.getKey();

				// getValue is used to get value of key in Map
				int value = (Integer) m.getValue();

				value--;

				if (value <= 0) {
					// remove value from map.
					it.remove();
				} else
					m.setValue(value);

				setPixel(key, value);

				doLoop = it.hasNext();

			} catch (ConcurrentModificationException e) {
				// TODO: handle exception
				System.out.println(e.toString());

				clearScreen();

				doLoop = false;
			}

			// getKey is used to get key of Map

			// System.out.println("Key :"+key+"  Value :"+value);
		}

		if (isDrawing)
			parent.updatePixels();

		isDrawing = false;

	}

	private void clearScreen() {
		map.clear();

		for (int i = 0; i < parent.pixels.length; i++) {
			setPixel(i,0);
		}

		parent.updatePixels();

	}

	void setPixel(int i, int value) {
		int colorInt = value;

		// parent.println("setPixels: " + key + ":" + value);
		i = Math.max(0, i);
		i = Math.min(i, parent.pixels.length-1);

		parent.pixels[i] = value;

	}

	private int getPixel(String s) {

		String coords[] = s.trim().split(",");
		int x = Integer.parseInt(coords[0].trim());
		int y = Integer.parseInt(coords[1].trim());

		int i = y * 16 + x;

		return i;
	}

	void receive(byte[] coord, String ip, int port) {

		if (isDrawing) {
			return;
		}

		String s = new String(coord);
		parent.println(" " + s + " from " + ip + ".  " + map.containsKey(s));

		int i = getPixel(s);
		map.put(i, 255);
		setPixel(i, 255);

		// if (map.containsKey(s)) {
		// // boost objects brightness
		//
		// } else {
		// // add new object
		//
		// parent.println(" " + s + ":" + coord + " from " + ip + ".  " +
		// map.containsKey(s));
		//
		// }

	}

}

