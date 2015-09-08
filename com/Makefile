# java Walker utilities.
# Trying to make one massive .jar with everything we need.
# user must define the main class on the java command line

BIN = /home/aaron/workspace/boimUtil/bin

# path under com/boim:
JCLASS = optimize/QualityMetric.class optimize/NelderMeadSimplex.class walker/JansenMetric.class \
	walker/OptJansen.class walker/tests/PruneBadConfigurationList.class \
	walker/tests/BalancePruneList.class walker/tests/plotJansen.class \
	walker/SplitList.class walker/JansenMetric$$StrideOrbit.class walker/JansenLinkage.class \
	walker/WalkerLinkage.class walker/BadConfigurationList.class \
	walker/JansenMetric$$MetricParts.class walker/WalkerMetric$$StrideStats.class \
	util/BasicStats.class util/PointNode.class util/SVGPlot.class \
	walker/tests/AnimOrbit.class

PCLASS = $(JCLASS:%=com/boim/%)

walker.jar:
	cd $(BIN);jar cvf walker.jar $(PCLASS)

