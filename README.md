# Compressive Fourier-Domain Intensity Coupling (C-FOCUS)

Code accompanying the manuscript:

> **“Compressive Fourier-Domain Intensity Coupling (C-FOCUS) enables near-millimeter deep imaging in the intact mouse brain in vivo”**  
> R. He, Y. Li, B. Urbina, J. Wan, and Y. Xue  
> arXiv:2505.21822

C-FOCUS is an active scattering correction approach for two-photon microscopy that integrates Fourier-domain intensity modulation with compressive sensing. 
It enables high-contrast, high-resolution imaging of neuronal and vascular structures at depths near 1 mm in the intact mouse brain and through the intact adult mouse skull.

---

## Repository overview

This repository contains:

- **Core algorithms: RUNME_CFOCUS.mat**
  - Control hardware in the imaging system as described in Methods. It needs to be run while connecting to the hardware.
  - Image acquisition and processing

- **Functions for hardware control**
  - **Initialization: function_initializeAllHardware**
  - **Control DMD projection:**
  -   function_PatternGenerator2D
  -   function_feed_DMD
  -   function_ProjInquire_DMD
  -   function_StoreImages_DMD
  -   function_StoreAndProjection
  -   function_StartProj_DMD
  -   function_StopProj_DMD
  -   function_SeqFree_DMD
  -   function_Stop_DMD
  - **Generate trigger signals for synchronization using a NI DAQ**
  -   function_makeCycleClock
  -   function_makeCycleClockGMscan
  -   function_makeCycleClockMultiROI
  - **Generate correction masks**
  -   function_FindTargets
  -   function_FISTA
  -   function_GenerateSubregionMask
  - **Image acquisition via point scanning**
  -   function_StoreAndProjectionAndScan
  -   function_StoreAndProjectionPMTon
  - **Image processing**
  -   function_imgprocess_MultiFISTA
  -   function_imgprocess_notchfilter
  -   function_imgprocess_removeGrid_step1
  -   function_imgprocess_removeGrid_step2

