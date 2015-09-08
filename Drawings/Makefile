# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/Makefile $
# $Id: Makefile 431 2015-03-01 14:07:25Z mrwhat $

BASENAME = Jansen
KBASE = Klann

# set to your path.  Needs to be actual source path to find sub-modules
SLIC3R = /usr/local/slic3r/Slic3r/slic3r.pl
SLIC3R = /usr/local/Slic3r/bin/slic3r

# For each half (2-leg) assembly, print:
# (1) main, crankArm, BEDa, BEDb, FootA, FootB
# (2) CH, CD
# (4) EF, BH
# print one pulley for each full (4-leg) assembly

JANSEN_PARTS = main crankLinks BHs EFs Feet Hip
OTHER_PARTS = basketMount electronicsMountBrim motorMountBrim pulley_pad drivePulley_pad brace
#spacer
# crankArm CH CD BH EF BEDa BEDb FootA FootB

JANSEN_STL = $(JANSEN_PARTS:%=$(BASENAME)_%.stl)
OTHER_STL = $(OTHER_PARTS:%=$(BASENAME)_%.stl)

JANSEN_GCODE = $(JANSEN_PARTS:%=$(BASENAME)_%.gcode)
OTHER_GCODE = $(OTHER_PARTS:%=$(BASENAME)_%.gcode)

MAINDEP = $(BASENAME).scad $(BASENAME)Defs.scad

# one copy of each UNIQUE part used to build Jansen-style walking linkage
JANSEN_BASE = mainBar AC CH CD BH EF HipA HipB jHipA jHipB FootA FootB \
	braceBar pulley drivePulley motorMount electronicsMount basketMount

JANSEN_BASE_STL = $(JANSEN_BASE:%=$(BASENAME)_%.stl)

# default is from Jansen
#all:	Jansen13.zip
all:	Jansen14Base.zip

Jansen12.zip:	$(JANSEN_GCODE) $(OTHER_GCODE) $(JANSEN_STL) $(OTHER_STL)
	rm  -f $@
	zip -r $@ Jansen.scad JansenDefs.scad pulley.scad JansenBED.scad \
		JansenFoot.scad JansenMain.scad \
		driveElectronicsMount.scad motorMount.scad basketMount.scad \
		Makefile \
		$(JANSEN_STL)   $(OTHER_STL) \
		$(JANSEN_GCODE) $(OTHER_GCODE)

Jansen13.zip:	$(JANSEN_BASE_STL) $(OTHER_STL)
	rm  -f $@
	zip -r $@ Jansen.scad JansenDefs.scad pulley.scad JansenBED.scad \
		JansenFoot.scad JansenMain.scad \
		driveElectronicsMount.scad motorMount.scad basketMount.scad \
		Makefile NOTES3D.html \
		$(JANSEN_BASE_STL)   $(OTHER_STL)

stl:	$(JANSEN_STL)

misc:	$(OTHER_STL)

# base, unpadded parts
Jansen14Base.zip:	$(JANSEN_BASE_STL)
	rm -f $@
	zip -r $@ $(JANSEN_BASE_STL) \
		JansenLinkages.png README.html Building.html

%.gcode:	%.stl QuelabJansenConfig.ini
	$(SLIC3R) --load QuelabJansenConfig.ini $<

# Special STL rules
$(BASENAME)_motorMount.stl:	 motorMount.scad $(BASENAME)Defs.scad
	openscad -o $@ $<

$(BASENAME)_motorMountBrim.stl:	 motorMount.scad $(BASENAME)Defs.scad
	openscad -o $@ -D WITH_BRIM=1 $<

$(BASENAME)_electronicsMount.stl:	 driveElectronicsMount.scad $(BASENAME)Defs.scad
	openscad -o $@ $<

$(BASENAME)_electronicsMountBrim.stl:	 driveElectronicsMount.scad $(BASENAME)Defs.scad
	openscad -o $@ -D WITH_BRIM=1 $<

$(BASENAME)_basketMount.stl:	basketMount.scad $(BASENAME)Defs.scad
	openscad -o $@ $<

# generic STL rule for Jansen parts
$(BASENAME)_%.stl:	$(MAINDEP)
	openscad -o $@ -D 'PART="$*"' $<

klann:	$(KBASE).scad
	openscad -o $(KBASE)_main.stl -D 'PART="main"' $(KBASE).scad
	openscad -o $(KBASE)_crankArm.stl -D 'PART="AC"' $(KBASE).scad
	openscad -o $(KBASE)_pulley.stl -D 'PART="pulley"' $(KBASE).scad
	openscad -o $(KBASE)_rocker.stl -D 'PART="rocker"' $(KBASE).scad
	openscad -o $(KBASE)_DE.stl -D 'PART="DE"' $(KBASE).scad
	openscad -o $(KBASE)_BH.stl -D 'PART="BH"' $(KBASE).scad
	openscad -o $(KBASE)_leg.stl -D 'PART="leg"' $(KBASE).scad

jig:	linkageJig.scad
	openscad -o jigBase.stl -D 'PART="Base"' linkageJig.scad
	openscad -o jigBar.stl -D 'PART="Bar"' linkageJig.scad

# This drawing can be imported into the ponoko Inkscape template.
# just rescale (retaining aspect ratio) to 181x181 mm after import
%.dxf:	%.pl
	perl -w $< | perl -w toProduction.pl > temp.svg
	inkscape -E temp.eps temp.svg
	pstoedit -dt -f 'dxf:-polyaslines -mm' temp.eps $@

# this prevents make chain rues from removing _preview.svg files as ".INTERMEDIATE"
.SECONDARY:
	%.svg

# rule to make ALL current laser-cut drawings:
#laserCut:	laserCutP2Sthick.svg laserCutP2Sthick_preview.png \
#		laserCutP2thick.svg  laserCutP2thick_preview.png \
#		laserCutP2thin.svg  laserCutP2thin_preview.png
laserCut:	lc20thinP2.svg lc20midP1.svg lc20ThickP2.svg spacersP1.svg

# special rule for non-square Pololu stock
%1x2_preview.png:	%1x2_preview.svg
	inkscape -z -e $@ -w 2048 -h 1024 $<

# generic rule to convert preview.svg to .png
%_preview.png:	%_preview.svg
	inkscape -z -e $@ -w 1024 -h 1024 $<

# definitions and sub-functions used to make laser cut drawings
LASER_DEPS = laserCutPartsGroups.pl laserCutPartsPrimitives.pl JansenDefs.pl payloadBox.pl involuteGear.pl motorMount.pl

###### _preview.svg is depricated.
#  Just build the .svg (which is now a preview).
#  Edit the first few lines in the header.  Delete the background rectangle and border
#  as indicated.  Then set stroke-width and stroke color as desired for cutting/DXF conversion

# if the name has _preview in it, let this override default (production) rule
%_preview.svg:	%.pl $(LASER_DEPS)
	perl -w $< > $@
######

# default rule, clear background with thin stroke as required by ponoko
%.svg:	%.pl $(LASER_DEPS)
	perl -w $< ponoko > $@

clean:
	\rm -f $(JANSEN_STL) $(OTHER_STL) $(JANSEN_BASE_STL)
