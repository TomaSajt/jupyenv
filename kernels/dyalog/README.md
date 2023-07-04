# JupyterWith Dyalog

The Dyalog kernel can be used as follows:

```nix
{
iNix = jupyter.kernels.dyalogKernel {
    # Identifier that will appear on the Jupyter interface.
    name = "Dyalog-kernel";
  };
}
```
