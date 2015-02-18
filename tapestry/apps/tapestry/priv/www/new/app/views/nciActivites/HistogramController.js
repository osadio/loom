(function (angular) {
    'use strict';

    angular.module('nci.activitiesView.HistogramController', [
        'googlechart',
        'nci.components.services.endpointsService',
    ])
        .controller('HistogramController', [
            "$scope",
            "nciEndpointsDialog",
        function($scope, nciEndpointsDialog) {
            function createTooltip(activity) {
                return [
                    'Activity #' + activity.index,
                    'Size: ' + activity.size,
                    'Internal Flows: ' + activity.internalFlows,
                    'External Flows: ' + activity.externalFlows,
                    'Average Internal Flows: ' + activity.avgInternalFlows.toFixed(2)
                ].join("\n");
            }
            var activities = $scope.activities,
                details = activities.all(),
                maxActivities = new Set(details.slice().sort(function(activity1, activity2) {
                     return activity2.internalFlows - activity1.internalFlows;
                }).filter(function(d, i) {
                     return i < 5 && d.internalFlows > 0;
                })),
                rows = details.map(function(activity) {
                    return {c: [
                        {v: "Activity #" + activity.index, f: "", ip: activity.mainEndpoint.ip},
                        {v: activity.size},
                        {v: createTooltip(activity)},
                        {v: maxActivities.has(activity) ? "#2ca02c" : null}
                    ]};
                });


            $scope.chartObject = {};

            $scope.select = function(selection) {
                if (selection) {
                    var activity = activities.byIp(rows[selection.row].c[0].ip);
                    nciEndpointsDialog.show(activity);
                }

            };

            $scope.chartObject.data = {"cols": [
                {id: "t", label: "Label", type: "string"},
                {id: "s", label: "Size", type: "number"},
                {role: "tooltip", type: "string"},
                {role: "style", type: "string"}
            ], "rows": rows};

            // $routeParams.chartType == BarChart or PieChart or ColumnChart...
            //$scope.chartObject.type = "google.charts.Bar";
            $scope.chartObject.type = "ColumnChart";

            $scope.chartObject.options = {
                //'title': 'Activities distribution',
                //"isStacked": "true",
                "legend": "none",
                "vAxis": {
                    "logScale": "true",
                    // scale type is used to start scale with ~0
                    "scaleType": "mirrorLog",
                    "title": "Number of Endpoints per Activity X[j]"
                },
                "hAxis": {
                    "labels": "false",
                    "title": 'Activities Sorted by Size'
                }
            };

        }]);

})(angular);
