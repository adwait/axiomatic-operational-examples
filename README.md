# axiomatic-operational-examples

This repository contains examples for verification 
of RTL designs with operational models.

Note that running the examples in this repository will require an installation of [SymbiYosys](https://symbiyosys.readthedocs.io/en/latest/index.html). Please follow the [installation instructions](https://symbiyosys.readthedocs.io/en/latest/install.html).


Currently backend solvers have been configured to be [boolector](https://boolector.github.io/) for BMC proofs and [abc](https://people.eecs.berkeley.edu/~alanmi/abc/) for PDR proofs. The installation instructions for these can also be found at the above link. Alternatively, you can try different solvers too (refer to above link for details). All installed software should be on your `$PATH`.

Once all requirements (`SymbiYosys` and solvers) are satisfied, the examples can be run either by executing the main script `run-main.sh` or each example script individually. Enjoy!
