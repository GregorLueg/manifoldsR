use extendr_api::{RArray, RMatrix};
use faer::Mat;
use faer_entity::SimpleEntity;

////////////
// Traits //
////////////

////////////////
// R and faer //
////////////////

/// Bridge between faer matrix types and R matrix types.
///
/// Defines how to convert faer matrices to R-compatible arrays.
pub trait FaerRType: SimpleEntity + Copy + Clone + 'static {
    type RType: Copy + Clone;
    fn to_r_matrix(x: faer::MatRef<Self>) -> extendr_api::RArray<Self::RType, [usize; 2]>;
}

impl FaerRType for f64 {
    type RType = f64;
    fn to_r_matrix(x: faer::MatRef<Self>) -> extendr_api::RArray<Self, [usize; 2]> {
        let nrow = x.nrows();
        let ncol = x.ncols();
        RArray::new_matrix(nrow, ncol, |row, column| x[(row, column)])
    }
}

impl FaerRType for i32 {
    type RType = i32;
    fn to_r_matrix(x: faer::MatRef<Self>) -> extendr_api::RArray<Self, [usize; 2]> {
        let nrow = x.nrows();
        let ncol = x.ncols();
        RArray::new_matrix(nrow, ncol, |row, column| x[(row, column)])
    }
}

impl FaerRType for f32 {
    type RType = f64;
    fn to_r_matrix(x: faer::MatRef<Self>) -> extendr_api::RArray<f64, [usize; 2]> {
        let nrow = x.nrows();
        let ncol = x.ncols();
        RArray::new_matrix(nrow, ncol, |row, column| x[(row, column)] as f64)
    }
}

/////////////
// Helpers //
/////////////

/// Transform an R matrix into a f32 one
///
/// ### Params
///
/// * `x` - R matrix with f64.
///
/// ### Returns
///
/// A faer Mat with f32
pub fn r_matrix_to_faer_fp32(x: &RMatrix<f64>) -> Mat<f32> {
    let ncol = x.ncols();
    let nrow = x.nrows();
    let data = x.data();
    let data_fp32 = data.iter().map(|x| *x as f32).collect::<Vec<f32>>();
    Mat::from_fn(nrow, ncol, |i, j| data_fp32[i + j * nrow])
}

/// Transform a faer into an R matrix
///
/// ### Params
///
/// * `x` - faer `MatRef` matrix to transform into an R matrix
///
/// ###
///
/// The R matrix based on the faer matrix.
pub fn faer_to_r_matrix<T: FaerRType>(
    x: faer::MatRef<T>,
) -> extendr_api::RArray<T::RType, [usize; 2]> {
    T::to_r_matrix(x)
}
