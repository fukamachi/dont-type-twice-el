# dont-type-twice.el --- Supports your effective text editing.

## What's this?

dont-type-twice.el is an utility to make you not to type same thing twice.
This library notifies when you typed same command twice.

## Qualification

This library tested with GNU Emacs 23.1 on Ubuntu 10.04 and Mac OS 10.6 only.

## Installation

Download dont-type-twice.el (this file) and put into your load-path.

If you are ready to use auto-install.el (http://www.emacswiki.org/emacs/auto-install.el), just put below code to your *scratch* and eval it.

    (auto-install-from-url "http://github.com/fukamachi/dont-type-twice-el/raw/master/dont-type-twice.el)

## Settings

Put following code into your .emacs.el.

    (require 'dont-type-twice)
    (global-dont-type-twice t)

And you open a file, then find to be notified on minibuffer when you did something stupid.
Isn't it enough? You can change notification func for you.
Set `dt2-notify-send' to dt2-notify-func, for example

    (setq dt2-notify-func 'dt2-notify-send)

You would receive notification with notify-send.
For Mac users, it would be `dt2-growl' instead.

## License

Copyright (C) 2010  深町英太郎 (E.Fukamachi) <e.arrows@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
