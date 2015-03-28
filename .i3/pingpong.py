#!/usr/bin/python3

import sys,os,tempfile
import cairo
from gi.repository import Gtk, Gdk, GLib
import math, threading, time, random

class SingleInstance:
    """
    If you want to prevent your script from running in parallel just instantiate
    SingleInstance() class. If is there another instance already running it will
    exist the application with the message "Another instance is already running,
    quitting.", returning -1 error code.

    >>> me = SingleInstance()
    """
    def __init__(self):
        self.lockfile = os.path.normpath(tempfile.gettempdir() + '/' +
          os.path.splitext(os.path.abspath(__file__))[0].replace("/","-").replace(":","").replace("\\","-")  + '.lock')
        import fcntl, sys
        self.fp = open(self.lockfile, 'w')
        try:
          fcntl.lockf(self.fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except IOError:
          sys.exit(-1)

class Bat:
    Left = 0
    Right = 1

class MyWin (Gtk.Window):
    _sr = 0; _sl = 0        # score left and right
    _batvelocdef = 10       # default bat velocity
    _batveloc = 0           # current but velocity
    _batlen = 0             # bat length
    _batwidth = 0           # bat width
    _batlenhalve = 0        # bat length halved
    _batact = Bat.Left      # bat receiving the ball
    _batl = 0               # left bat y position
    _batr = 0               # rigth bat y position
    _ballx = 0; _bally = 0  # ball position x,y
    _ballside = 0           # ball side size
    _ballvec = 0.0          # ball vector
    _ballveloc = 0.0        # ball current velocity
    _ballvelocdef = 10.0    # ball default velocity 
    _startGame = False      #
    _startGameTime = 0.0    # game start time
    _prevFrameTime = 0.0    # previous frame time
    _fps = 0.0              # fps
    _winWidth = 0           # window width
    _winHeight = 0          # window height
    _digRowHeight = 0       # score digits row height
    _digColWidth = 0        # score digits column width
    _goalanimation = False  # animate the ball
    _manual = False         # if man vs computer
    _showDebug = False      # shows debug info
    _digits = [ [0xf9,0x99,0xf0],[0x11,0x11,0x10],[0xf1,0xf8,0xf0],[0xf1,0xf1,0xf0],[0x99,0xf1,0x10],
                [0xf8,0xf1,0xf0],[0xf8,0xf9,0xf0],[0xf1,0x11,0x10],[0xf9,0xf9,0xf0],[0xf9,0xf1,0xf0] ]

    def key_pressed(self, widget, event):
      print("key: ", event.keyval, "; state: ", int(event.state))
      # Ctrl-C or Esc - Exit
      if event.keyval == 65307 or \
         (event.keyval == 99 and event.state == 4):
        Gtk.main_quit()
      elif event.keyval == 65362: # up arrow
        #widget.Up()
        widget.queue_draw()
      elif event.keyval == 65364: # down arrow
        #widget.Down()
        widget.queue_draw()
      elif event.keyval == 109:   # M is pressed
        self._manual = not self._manual
      elif event.keyval == 100:   # D is pressed
        self._showDebug = not self._showDebug
      return False

    def motion_notify_event(self, widget, event):
      if not self._manual:
        return True
      self._batr = int(event.y)
      if self._batr < self._batlenhalve:
        self._batr = self._batlenhalve
      elif self._batr > self._winHeight - self._batlenhalve:
        self._batr = self._winHeight - self._batlenhalve
      return True

    def configure(self, widget, event):
      if self._winHeight!=event.width and self._winWidth!=event.width:
        self._winHeight = event.height
        self._winWidth = event.width
        self._digRowHeight = int(self._winHeight/38)
        self._digColWidth  = int(self._winWidth/90)
        self._batlen = int(self._winHeight/5)
        self._batwidth = self._digRowHeight
        self._batlenhalve = int(self._batlen/2)
        self._batlead = Bat.Left
        self._ballside = self._digRowHeight
        random.seed()
        self.init_game()

    def transp_setup(self):
      self.set_app_paintable(True)  
      screen = self.get_screen()
                    
      visual = screen.get_rgba_visual()       
      if visual != None and screen.is_composited():
        self.set_visual(visual) 

    def __init__(self):
      super(MyWin, self).__init__()
      # seems like full screen app canno't be transparent
      #self.transp_setup()
      self.connect("draw", self.area_draw)
      self.connect("delete-event", Gtk.main_quit)
      self.connect("key-press-event", self.key_pressed)
      self.connect("configure-event", self.configure)
      self.connect("motion_notify_event", self.motion_notify_event)
      self.add_events(Gdk.EventMask.POINTER_MOTION_MASK) 

      self.set_keep_above(True)
      self.set_skip_taskbar_hint(True)
      self.stick()
      self.fullscreen()
      self.show_all()

    def move_bat(self, batpos, ballpos, veloc, active):
      diff = ballpos - batpos
      if diff>0 and diff>=veloc:
        diff = veloc
      elif diff<0 and diff<=-veloc:
        diff = -veloc

      if active:
        batpos+=diff 
        if (batpos - self._batlenhalve) < 0:
          batpos = int(self._batlenhalve)
        elif (batpos + self._batlenhalve) > self._winHeight:
          batpos = int(self._winHeight - self._batlenhalve)
      else:
        if batpos+veloc < self._winHeight/2:
          batpos+= veloc
        if batpos-veloc > self._winHeight/2:
          batpos-= veloc
      return batpos

    def add_random_angle(self, angle):
      rangle = (45 - random.randint(0,90))
      rangle*=math.pi/180.0
      return angle+rangle

    def timer_tick(self):
      if self._startGame == False:
        return;
 
      if self._goalanimation:
        self._ballveloc = 0.5
      else:
        # ball velocity doubles in one minute
        self._ballveloc = self._ballvelocdef+(self._ballvelocdef*(time.perf_counter()-self._startGameTime)/60)
 
      self._ballx = self._ballx + self._ballveloc*math.sin(self._ballvec)
      self._bally = self._bally + self._ballveloc*math.cos(self._ballvec)

      # local integer ball position
      x = int(self._ballx)
      if  self._goalanimation:
        if x<=0 or x>=self._winWidth - self._ballside:
          self.init_game()
        return
 
      # ball should not be off the table bacase bats can't be
      if self._bally<0:self._bally=0
      elif self._bally>(self._winHeight-self._ballside):self._bally=self._winHeight-self._ballside
      y = int(self._bally)

      if Bat.Left == self._batact: # left bat receives the ball
        self._batl = self.move_bat(self._batl, y, self._batveloc, True)
        if not self._manual:
          self._batr = self.move_bat(self._batr, y, self._batveloc, False)
      else:
        self._batl = self.move_bat(self._batl, y, self._batveloc, False)
        if not self._manual:
          self._batr = self.move_bat(self._batr, y, self._batveloc, True)

      # bouncing from right side
      if x >= (self._winWidth - (self._ballside+self._batwidth)): 
        if (y <= self._batr + self._batlenhalve) and \
           (y >= self._batr - self._batlenhalve):
           if self._batact == Bat.Right:
             self._ballvec = self.add_random_angle(1.5*math.pi)
             self._batact = Bat.Left
        else:
          print("ballx:",self._ballx,"bally=",self._bally," batup=",self._batr-self._batlenhalve," batdwn=",self._batr+self._batlenhalve)
          self._sl+=1
          self._batlead = Bat.Left
          self._goalanimation = True
          return
          #self.init_game() 
      # bouncing from the left side 
      elif x <= self._batwidth: 
        if (y <= self._batl + self._batlenhalve) and \
           (y >= self._batl - self._batlenhalve):
          if self._batact == Bat.Left:
            self._ballvec = self.add_random_angle(math.pi/2)
            self._batact = Bat.Right
        else:
          print("ballx:",self._ballx,"bally=",self._bally," batup=",self._batl-self._batlenhalve," batdwn=",self._batl+self._batlenhalve)
          self._sr+=1
          self._batlead = Bat.Right
          self._goalanimation = True
          return
          #self.init_game()
      # bouncing top or bottom  
      if y + self._ballside >= self._winHeight:
        self._ballvec = math.pi - self._ballvec
      elif y <= 0:
        self._ballvec = math.pi - self._ballvec

    def start_game(self):
      self._startGame = True
      self._startGameTime = time.perf_counter()
      self.queue_draw()
      return False

    def init_game(self):
      self._startGame = False
      self._goalanimation = False
      self._ballx = self._ballside if Bat.Left == self._batlead else self._winWidth-2*self._ballside
      self._bally = self._winHeight/2 - self._ballside/2
      self._ballvec = self.add_random_angle(0)
      if Bat.Left == self._batlead:
        self._ballvec+=math.pi/2
      else:
        self._ballvec+=1.5*math.pi
      self._ballveloc = self._ballvelocdef 
      self._batr = int(self._winHeight/2)
      self._batl = int(self._batr)
      self._batveloc = self._batvelocdef
      self._batact = Bat.Right if Bat.Left == self._batlead else Bat.Left 
      GLib.timeout_add(1000, self.start_game)
      self.queue_draw()

    def draw_digit_raw(self, cr, nibble, x, y):
      nibble%= 0x10
      if 0 == nibble:
        return 
      i = 8
      while i!=0:
        if nibble & i > 0:
          cr.rectangle(x, y, self._digColWidth, self._digRowHeight)
        x+=self._digColWidth
        i = i >> 1

    def draw_digit(self, cr, digit, x, y):
      digit = digit % 10
      cy = y
      for segm in self._digits[digit]:
        self.draw_digit_raw(cr, segm >> 4, x, cy)
        cy+=self._digRowHeight
        self.draw_digit_raw(cr, segm & 0x0F, x, cy)
        cy+=self._digRowHeight

    def draw_score(self, cr):
      cr.set_source_rgb(1.0, 1.0, 1.0)
      self._sr%=100;self._sl%=100 # only 2 digits are allowed
      digWidth = self._digColWidth * 5
      self.draw_digit(cr, int(self._sl/10), self._winWidth/2 - (digWidth*2) - self._digColWidth, self._digRowHeight)  
      self.draw_digit(cr, self._sl-10*int(self._sl/10), self._winWidth/2 - (digWidth) - self._digColWidth, self._digRowHeight)  
      self.draw_digit(cr, int(self._sr/10), self._winWidth/2 + (2*self._digColWidth), self._digRowHeight)  
      self.draw_digit(cr, self._sr-10*int(self._sr/10), self._winWidth/2 + (digWidth+2*self._digColWidth), self._digRowHeight)  
      cr.fill() 

    def draw_net(self, cr):
      cr.set_source_rgb(1.0, 1.0, 1.0)
      cr.move_to(self._winWidth/2, 0)
      cr.set_line_width(self._digColWidth/3)
      cr.line_to(self._winWidth/2, self._winHeight)
      cr.set_dash([2*self._digColWidth/3], 0)
      cr.stroke() 
      
    def draw_ball(self, cr):
      cr.set_source_rgb(1.0, 1.0, 0.3)
      cr.rectangle(self._ballx, self._bally, self._ballside, self._ballside)
      cr.fill()

    def draw_background(self, cr):
      cr.set_source_rgba(0.0, 0.0, 0.0, 1.0)
      cr.set_operator(cairo.OPERATOR_SOURCE)
      cr.paint()
      cr.set_operator(cairo.OPERATOR_OVER)

    def draw_bat(self, cr, bat):
      cr.set_source_rgb(1.0, 1.0, 1.0)
      if Bat.Left == bat:
        cr.rectangle(0, self._batl-self._batlen/2, self._batwidth, self._batlen)
      else:
        cr.rectangle(self._winWidth - self._batwidth, self._batr-self._batlen/2 , self._batwidth, self._batlen)
      cr.fill()

    def draw_debug(self, cr):
      if not self._showDebug:
        return
      cr.set_source_rgb(1.0, 1.0, 1.0)
      cr.set_font_size(8)
      cr.move_to(10,10)
      cr.show_text("ball vector: "+ '%.5f' %  self._ballvec)
      cr.move_to(10,20)
      cr.show_text("ball veloc : "+ '%.5f' %  self._ballveloc)
      cr.move_to(10,30)
      cr.show_text("game time: "+ '%.2f' % (self._prevFrameTime-self._startGameTime))
      cr.move_to(10,40)
      cr.show_text("fps: "+ '%.1f' %  self._fps)

    def area_draw(self, widget, cr):
      cTime = time.perf_counter()
      self._fps = 1/(cTime - self._prevFrameTime)
      self._prevFrameTime = cTime
      (x,y) = self.get_window().get_position()
      self.draw_background(cr)
      self.draw_score(cr)
      self.draw_net(cr)
      self.draw_ball(cr)
      self.draw_bat(cr,False)
      self.draw_bat(cr,True)
      self.draw_debug(cr)
      self.timer_tick()
      self.queue_draw()
      return True

def main(argv):
  me = SingleInstance()
  MyWin();
  Gtk.main()

if __name__ == "__main__":
  main(sys.argv)

