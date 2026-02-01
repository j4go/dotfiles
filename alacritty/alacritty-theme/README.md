# Alacritty Theme

Collection of colorschemes for easy configuration of the [Alacritty terminal
emulator].

[Alacritty terminal emulator]: https://github.com/alacritty/alacritty

## Installation

### Imports

Clone the repository, or download the theme of your choice:

```sh
# We use Alacritty's default Linux config directory as our storage location here.
mkdir -p ~/.config/alacritty/themes
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

Add an import to your `alacritty.toml` (Replace `{theme}` with your desired
colorscheme):

```toml
[general]
import = [
    "~/.config/alacritty/themes/themes/{theme}.toml"
]
```


[alacritty-theme]: https://github.com/alacritty/alacritty-theme

To add a new theme, please create a Pull Request. Note that submissions by theme
authors are not accepted, to ensure there's at least some community interest.
The following changes must be made for a new theme:

 - Add your theme to the `themes` directory with the `{theme}.toml` file format
 - Create a screenshot of your theme using the [`print_colors.sh`](./print_colors.sh) script
 - Add the screenshot to the `images` directory with the `{theme}.png` file format
 - Add your theme to the `README.md`, following alphabetical ordering

