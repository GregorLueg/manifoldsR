# Adjusted Rand index

**\[experimental\]** Calculates the adjusted Rand index in Rust between
two membership vectors.

## Usage

``` r
rs_ari(cluster_membership_a, cluster_membership_b)
```

## Arguments

- cluster_membership_a:

  Integers. Cluster memberships in group a.

- cluster_membership_b:

  Integers. Cluster memberships in group b.

## Value

Returns the adjusted Rand index between the two groups.
