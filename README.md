# SmartBaton

The software required for a smart conducting baton, using UltraLeap skeletal technology and IMU calculations, to track, display, and analyse conducting movements.

## Contents

### Data
This folder contains the files of pure data. There's raw unmanipulated data from experiments, and intermediate/maniuplated data from data manipulation.

### DataCapture
This folder contains the scripts created to read in mechanical data, i.e. accelerometer and IMU data.

### DataManipulation
This folder contains the scripts created to manipulate the data. For info on what steps have been done, see the [DataManipulation markdown](/DataManipulation/DataManipulation_README.md).

### DataVisualisation
This folder contains the scripts created to visualise the data (both raw and manipulated).  This system assigns a unique identifier to all visualisations. `GUID_Directory.xlsx` gives a detailed description of each unique visualisation, including things like the dataset, details, and date.

See the [data viz readme](/DataVisualisation/DataVisualisation_README.md) for how to use this system.

### Visualisations
This folder contains images and .figs of data (both raw and manipulated).
