# manifoldsR: Fast Low-Dimensional Embeddings and Clustering via 'Rust'

R interface to the Rust crates 'manifolds-rs', 'ann-search-rs' and
'evoc-rs'. Builds 2D (or higher) embeddings with UMAP (McInnes et al.,
2018)
[doi:10.48550/arXiv.1802.03426](https://doi.org/10.48550/arXiv.1802.03426)
, t-SNE (van der Maaten and Hinton, 2008)
<https://jmlr.org/papers/v9/vandermaaten08a.html>, densMAP and den-SNE
(Narayan et al., 2021)
[doi:10.1038/s41587-020-00801-7](https://doi.org/10.1038/s41587-020-00801-7)
, PHATE (Moon et al., 2019)
[doi:10.1038/s41587-019-0336-3](https://doi.org/10.1038/s41587-019-0336-3)
, PaCMAP (Wang et al., 2021) <https://jmlr.org/papers/v22/20-1061.html>,
ForceAtlas2 (Jacomy et al., 2014)
[doi:10.1371/journal.pone.0098679](https://doi.org/10.1371/journal.pone.0098679)
, DREAMS and diffusion maps. Also generates approximate nearest
neighbour graphs that every method can reuse, plus EVoC and k-means
clustering. Multi-threaded via 'Rayon', with f32 or f64 precision.

## See also

Useful links:

- <https://gregorlueg.github.io/manifoldsR/>

- <https://github.com/GregorLueg/manifoldsR>

- Report bugs at <https://github.com/GregorLueg/manifoldsR/issues>

## Author

**Maintainer**: Gregor Lueg <gregorlueg@me.com>

Authors:

- Gregor Lueg <gregorlueg@me.com>

- Grant Neilson <grant.neilson5@gmail.com>

Other contributors:

- Authors of the dependency Rust crates (see inst/AUTHORS file)
  \[contributor, copyright holder\]
