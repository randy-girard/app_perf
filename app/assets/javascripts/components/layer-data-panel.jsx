window.LayerDataPanel = React.createClass({
  renderData: function(data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum) {
        url = updateQueryStringParameter(baseURI, "_layer", datum.name);
        return (
          <tr key={`layer-${datum.name}`}>
            <td className="ellipsis" key={`layer-${datum.name}-0`}>
              <a href={url}>{datum.name}</a>
            </td>
            <td width="100" key={`layer-${datum.name}-2`}>{datum.freq}</td>
            <td width="100" key={`layer-${datum.name}-3`}>{parseFloat(datum.avg).toFixed(2)}</td>
          </tr>
        )
      })
    )
  },

  render: function() {
    return (
      <DataPanel headers={this.props.headers}
                 title={this.props.title}
                 url={this.props.url}
                 callback={this.renderData} />
    )
  }
});

LayerDataPanel.defaultProps = {
  title: "Layers",
  headers: [
    "Layer",
    "Freq",
    "Avg"
  ]
};
