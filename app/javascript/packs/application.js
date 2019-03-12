/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import ReactChartkick, { AreaChart, LineChart } from './react-chartkick.js';

import Chartkick from './chartkick.js';
window.Chartkick = Chartkick;

import Chart from 'chart.js';
import 'chartjs-plugin-annotation';
import './chartjs-plugin-zoom.js';

ReactChartkick.addAdapter(Chart);

import WebpackerReact from 'webpacker-react';
WebpackerReact.setup({AreaChart, LineChart});

import moment from 'moment'
window.moment = moment

import Utils from './utils'
window.Utils = Utils

import ControllerDataPanel from 'components/ControllerDataPanel'
import DatabaseDataPanel from 'components/DatabaseDataPanel'
import HostDataPanel from 'components/HostDataPanel'
import LayerDataPanel from 'components/LayerDataPanel'
import TraceDataPanel from 'components/TraceDataPanel'
import UrlDataPanel from 'components/UrlDataPanel'
WebpackerReact.setup({
  ControllerDataPanel,
  DatabaseDataPanel,
  HostDataPanel,
  LayerDataPanel,
  TraceDataPanel,
  UrlDataPanel
});

$(document).ready(function() {
  Chartkick.eachChart(function(chart) {
    if(typeof(chart.options.library.zoom) !== 'undefined') {
      chart.options.library.zoom.onZoom = function(chart) {
        console.log(chart);
        var min = chart.chart.scales['x-axis-0'].min / 1000;
        var max = chart.chart.scales['x-axis-0'].max / 1000;

        var currentUrl = location.href;
        currentUrl = Utils.updateQueryStringParameter(currentUrl, "_past", "");
        currentUrl = Utils.updateQueryStringParameter(currentUrl, "_interval", "");
        currentUrl = Utils.updateQueryStringParameter(currentUrl, "_st", min);
        currentUrl = Utils.updateQueryStringParameter(currentUrl, "_se", max);

        window.location = currentUrl;
      }
    }
  });
});
