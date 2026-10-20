# synthetic data ---------------------------------------------------------------
#' Generate synthetic data for manifold learning
#'
#' @description A unified wrapper function for generating various types of
#' synthetic data to test manifold learning techniques and demonstrate
#' differences.
#'
#' @param type Character. Type of synthetic data to generate. One of:
#' \itemize{
#'  \item `"swiss_roll"` - Swiss roll manifold
#'  \item `"biased_swiss_roll"` - Biased Swiss roll manifold
#'  \item `"clusters"` - Clustered data
#'  \item `"trajectory"` - Trajectory-like data with branching
#'  \item `"hierarchical"` - Two-level hierarchical cluster structure
#' }
#' @param n_samples Integer. Number of data points to generate.
#' @param dim Integer. Dimensionality of the ambient space. Used for all types
#' except `"swiss_roll"`. Defaults to `32L`.
#' @param seed Integer. Seed for reproducibility. Defaults to `42L`.
#' @param parameters A named list of type-specific parameters, constructed via
#' [params_swiss_roll()], [params_swiss_roll_biased()] [params_clusters()],
#' [params_trajectory()], or [params_hierarchical()]. If `NULL`, defaults for
#' the chosen type are used. A plain list is accepted but must contain all
#' required fields for the given type.
#'
#' @return A list with the following elements:
#' \itemize{
#'  \item `data` - Numeric matrix of shape `n_samples x dim`
#'  \item `membership` - Integer vector of cluster/branch assignments (`NULL`
#'  for `"swiss_roll"`)
#' }
#'
#' @examples
#' d <- manifold_synthetic_data(type = "clusters", n_samples = 500L)
#' dim(d$data)
#' table(d$membership)
#'
#' roll <- manifold_synthetic_data(type = "swiss_roll", n_samples = 500L)
#' dim(roll$data)
#'
#' @export
manifold_synthetic_data <- function(
  type = c(
    "swiss_roll",
    "biased_swiss_roll",
    "clusters",
    "trajectory",
    "hierarchical"
  ),
  n_samples,
  dim = 32L,
  seed = 42L,
  parameters = NULL
) {
  renamed <- c(
    swiss_role = "swiss_roll",
    biased_swiss_role = "biased_swiss_roll"
  )
  if (length(type) == 1L && type %in% names(renamed)) {
    lifecycle::deprecate_warn(
      "0.5.0",
      I(sprintf('`manifold_synthetic_data(type = "%s")`', type)),
      I(sprintf('`type = "%s"`', renamed[[type]]))
    )
    type <- renamed[[type]]
  }
  type <- match.arg(type)
  checkmate::qassert(n_samples, "I1(0,)")
  checkmate::qassert(dim, "I1(1,)")
  checkmate::qassert(seed, "I1(1,)")

  if (is.null(parameters)) {
    parameters <- switch(
      type,
      swiss_roll = params_swiss_roll(),
      biased_swiss_roll = params_swiss_roll_biased(),
      clusters = params_clusters(),
      trajectory = params_trajectory(),
      hierarchical = params_hierarchical()
    )
  }

  switch(
    type,
    swiss_roll = assertSwissRollParams(parameters),
    biased_swiss_roll = assertSwissRollBiasedParams(parameters),
    clusters = assertClustersParams(parameters),
    trajectory = assertTrajectoryParams(parameters),
    hierarchical = assertHierarchicalParams(parameters)
  )

  switch(
    type,
    swiss_roll = {
      data <- with(
        parameters,
        rs_data_swiss_roll(
          n_samples = n_samples,
          noise = noise,
          seed = seed
        )
      )
      list(data = data, membership = NULL)
    },
    biased_swiss_roll = {
      data <- with(
        parameters,
        rs_data_biased_swiss_roll(
          n_samples = n_samples,
          bias = bias,
          noise = noise,
          seed = seed
        )
      )
      list(data = data, membership = NULL)
    },
    clusters = {
      result <- with(
        parameters,
        rs_data_clusters(
          n_samples = n_samples,
          dim = dim,
          n_clusters = n_clusters,
          seed = seed
        )
      )
      list(data = result$data, membership = as.integer(result$clusters))
    },
    trajectory = {
      result <- with(
        parameters,
        rs_data_trajectory(
          n_samples = n_samples,
          dim = dim,
          topology = topology,
          cell_trajectories = cell_trajectories,
          noise = noise,
          seed = seed
        )
      )
      list(data = result$data, membership = as.integer(result$branches))
    },
    hierarchical = {
      result <- with(
        parameters,
        rs_data_hierarchical(
          n_samples = n_samples,
          dim = dim,
          n_supergroups = n_supergroups,
          n_subclusts = n_subclusts,
          supergroup_spread = supergroup_spread,
          subcluster_spread = subcluster_spread,
          point_std = point_std,
          seed = seed
        )
      )
      list(
        data = result$data,
        membership = list(
          supergroup = as.integer(result$supergroup),
          subgroup = as.integer(result$subgroup)
        )
      )
    }
  )
}
