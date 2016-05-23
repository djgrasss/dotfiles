**Dotfiles**

To synchronize my setting over all my computers I'm using this git repository and a dotfiles management tool.

First I clone my own dotfiles from this repository into '~/dotfiles'. Then I copy the ~/dotfiles/.dotfilesrc file to the ~/ and start 'dotfiles -s'. And finally I create a 'bin' symlink in my home directory 'ln -s .bin bin'. Where .bin/ is a symlink created by the dotfiles manager and it points to the '~/dotfiles/.bin'

Dotfiles management tool I'm using can be cloned from the jbernard's github:
```
    $ git clone https://github.com/jbernard/dotfiles
    $ cd dotfiles
    $ ./dotfiles --help
```

