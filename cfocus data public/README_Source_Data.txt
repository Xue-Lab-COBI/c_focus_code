C-FOCUS Source Data for Figures 2-5
Prepared 19 October 2026

Associated study: Compressive Fourier-Domain Intensity Coupling (C-FOCUS)
enables near-millimeter deep imaging in the intact mouse brain in vivo.
Authors: Renzhi He, Yucheng Li, Brianna Urbina, Jiandi Wan and Yi Xue.
Project website: https://xue-lab-cobi.github.io/c_focus/
Paper: https://arxiv.org/abs/2505.21822
Code: https://github.com/Xue-Lab-COBI/c_focus_code

SCOPE AND ORGANIZATION
This deposit contains the available numerical data, image arrays and masks
organized for main Figures 2-5. It does not contain all acquisition files or
the source data for Supplementary Figures. Some images are processed display
images rather than raw detector-intensity measurements.
Each Fig2/Fig3/Fig4/Fig5 directory contains one file per included panel,
named a, b, c, etc. CSV files contain numerical data with header rows;
MAT files retain arrays and their variable names; TIFF files may contain
multiple pages or image series. PNG files are processed image exports.
The four Source_Data_Fig*.zip files can be extracted into one directory.
No original data values were modified during this publication packaging.
SHA256SUMS.txt can be used to verify each uncompressed data file.

FIGURE 2 (13 files)
a-d.mat: image and correction-mask arrays for the corresponding panels.
e.mat: separate masks for 2P-FOCUS and C-FOCUS (3,000 and 5,000 measurements).
f.csv: intensity measurements; explicitly labeled normalized columns are
normalized by the maximum original C-FOCUS intensity. The 2P-FOCUS point at
10,000 measurements is derived from the maximum of the panel-d source array.
g.mat: all 30 image/mask arrays from the supplied MATLAB figure, retaining
original axes order, coordinate metadata and display ranges.
h-k.csv: numerical measurements for the corresponding plots.
l-m.mat: original profile data, copied unchanged. The supplied source files
do not include physical position vectors or an explicit mapping of the ten
profiles to the nine listed power ratios. These mappings were not inferred.

FIGURE 3 (11 files)
a-c.tif: supplied shallow-depth image planes.
d.tif: the selected corrected three-dimensional image stack (vpz9 version).
This file does not include the uncorrected volume shown alongside it.
e-g.png: processed image exports.
h-j.csv: paired fluorescence-intensity profiles with/without correction.
l.mat: correction-mask data. Panel k is a schematic, with no experimental
source-data file.

FIGURE 4 (13 files)
a-c.tif: supplied shallow-depth image planes.
d.tif: the selected corrected three-dimensional image stack (No21 pkih).
This file does not include the uncorrected volume shown alongside it.
e-g.png: processed image exports.
h-j.csv: paired fluorescence-intensity profiles with/without correction.
k-m.mat: correction-mask data.

FIGURE 5 (10 files)
a.tif: three two-dimensional RGB image series for the skull and shallow
neuronal images. The three-dimensional rendering volume is not included.
b-d.tif: three RGB image series per panel: the full side-by-side comparison,
the uncorrected zoom, and the corrected zoom. These are processed displays,
not raw fluorescence-intensity matrices.
e-g.csv: numerical profile data extracted from the supplied MATLAB figures.
h-i.tif: original multipage mask TIFFs (nine and eight pages, respectively).
j.tif: the full 800 x 800 spatial-mask array from the supplied MATLAB figure.
Panel k is a schematic, with no experimental source-data file.
Some supplied image identifiers use '100umSkull', whereas the manuscript
reports 110 micrometres. These identifiers were retained in the source
arrays; they should not be used to reinterpret the manuscript's depths.

REUSE AND REPRODUCIBILITY
These files support inspection and reuse of the supplied measurements.
They are not a complete end-to-end raw acquisition/reconstruction archive.
In particular, the missing Figure 2l/m coordinate/mapping information,
Figure 5a three-dimensional volume and the uncorrected Figure 3d/4d volumes
are not supplied here. Do not infer these missing data from rendered plots.
