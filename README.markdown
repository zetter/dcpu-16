Ruby DCPU-16 Emulator
==================

Emulator for [Notch's DCPU-16](http://0x10c.com/doc/dcpu-16.txt).

Easter weekend project, wanted to see if I could use test-first every step of the way.
I setup a shortcut to commit for speedy working, so apologies for the generic commit messages.

To run:
---------------

`
Dcpu.new
Dcpu.load([1,2,3])
Dcpu.run
`

To test:
---------------

`
bundle
bundle exec rspec spec
`


To do:
---------------
 - overflows
 - non-basic instructions
 - more integration tests- an conditional test at the very least
 - assembler (meanwhile use an [existing assembler](https://github.com/toph/dcpu))