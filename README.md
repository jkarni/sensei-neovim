# sensei-neovim

A neovim plugin for [sensei](https://github.com/hspec/sensei).

# Usage

The following command opens a terminal buffer with compilation and test
outputs for you project.

```
:Sensei <file> [<opts>]
```

(E.g. `sensei test/Spec.hs`.) The buffer is reloaded automatically and
asynchronously with new results when anything in your directory changes. In the
buffer, you can use `n` and `N` to navigate backwards and forwards between file
locations, and `o` to open the file location under the cursor in a new buffer.

# Installation

## Pathogen

```
cd ~/.vim/bundle
git clone https://github.com/jkarni/sensei-neovim.git
```

## Vundle etc.

Add the following to your `vimrc`:

```
Bundle 'jkarni/sensei-neovim'
```

# More info

Check out the [docs](https://github.com/jkarni/sensei-neovim/blob/master/doc/sensei-neovim.txt) or type `:help sensei-neovim`
