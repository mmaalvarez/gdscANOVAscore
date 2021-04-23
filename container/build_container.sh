# ## debug the definition file (container.def)
# # create a writable empty container
# sudo singularity build --sandbox test.sandbox docker://centos:7
# # enter the container with writing permissions
# sudo singularity shell --writable test.sandbox/
# # and now basically run in the terminal the commands from the definition file's %post section, to check whether they work, and update the definition file accordingly

## when the definition file is debugged, create the .sif container based on it
sudo singularity build container.sif container.def
