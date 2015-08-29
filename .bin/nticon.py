#!/usr/bin/python

import os, sys, socket
from gi.repository import Gtk, Gdk, GdkPixbuf
from gi.repository.GdkPixbuf import Pixbuf
from gi.repository import GObject

class SingleInstance:
    def __init__(self):
      global lock_socket   # Without this our lock gets garbage collected
      process_name = "Interface thoughput icon"
      lock_socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
      try:
        lock_socket.bind('\0' + process_name)
        #print 'I got the lock'
      except socket.error:
        #print 'lock exists'
        sys.exit()


class MyStatusIcon:
    def __init__(self):
        self.statusicon = Gtk.StatusIcon()
        has_alpha = True
        bits_per_sample = 8
        width = 50; height = 50
        self.pixBuf = GdkPixbuf.Pixbuf.new(GdkPixbuf.Colorspace.RGB, has_alpha, bits_per_sample, width, height)
        self.pixBuf.fill(0x00000000)
        self.statusicon.set_from_pixbuf(self.pixBuf)
        self.statusicon.connect("popup-menu", self.right_click_event)
        self.statusicon.set_has_tooltip(True)
        res = self.get_net_bytes('wlan0')
        self.rx = res['rx']
        self.tx = res['tx']
        GObject.timeout_add(1000, self.redraw_icon)
        #window = Gtk.Window()
        #window.connect("destroy", lambda w: Gtk.main_quit())
        #window.show_all()

    def redraw_icon(self):
        result = self.get_net_bytes('wlan0')
        rxdiff = result['rx'] - self.rx
        txdiff = result['tx'] - self.tx
        self.statusicon.set_tooltip_markup("RX: %d\nTX: %d"% (rxdiff,txdiff))
        #print "%d %d"% (rxdiff,txdiff)
        self.pixBuf.fill(0x00000000)
        self.fill_left(rxdiff/102400.0)
        self.fill_right(txdiff/102400.0)
        self.rx = result['rx']
        self.tx = result['tx']
        self.statusicon.set_from_pixbuf(self.pixBuf)
        return True

    def fill_left(self, percent):
        if percent > 1.0:
            percent = 1.0
        if percent < 0.0:
            percent = 0.0
        y = int(50*(1-percent))
        if y == 50:
            return
        subbuf = self.pixBuf.new_subpixbuf(0,y,24,50-y)
        subbuf.fill(0xff0000ff)

    def fill_right(self, percent):
        if percent > 1.0:
            percent = 1.0
        if percent < 0.0:
            percent = 0.0
        y = int(50*(1-percent))
        if y == 50:
            return
        subbuf = self.pixBuf.new_subpixbuf(27,y,23,50-y)
        subbuf.fill(0x0000ffff)
    
    def get_net_bytes(self, dev='eth0'):
        """Read network interface traffic counters"""
        return {
            'rx': float(open('/sys/class/net/%s/statistics/rx_bytes' % dev,'r').read().strip()),
            'tx': float(open('/sys/class/net/%s/statistics/tx_bytes' % dev,'r').read().strip())
        }

    def right_click_event(self, icon, button, time):
        self.menu = Gtk.Menu()

        about = Gtk.MenuItem()
        about.set_label("About")
        quit = Gtk.MenuItem()
        quit.set_label("Quit")

        about.connect("activate", self.show_about_dialog)
        quit.connect("activate", Gtk.main_quit)

        self.menu.append(about)
        self.menu.append(quit)
        self.menu.show_all()

        def pos(menu, icon):
            return (Gtk.StatusIcon.position_menu(menu, icon))

        self.menu.popup(None, None, pos, self.statusicon, button, time)

    def show_about_dialog(self, widget):
        about_dialog = Gtk.AboutDialog()
        about_dialog.set_destroy_with_parent(True)
        about_dialog.set_name("Network interface thoughput systray icon")
        about_dialog.set_version("1.0")
        about_dialog.set_authors(["Alexander K"])
        about_dialog.run()
        about_dialog.destroy()

def main(argv):
  me = SingleInstance()
  newpid = os.fork()
  if newpid != 0:
    sys.exit()

  MyStatusIcon()
  Gtk.main()

if __name__ == "__main__":
  main(sys.argv)
