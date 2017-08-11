window.DatabaseDataPanel = React.createClass({
  renderData: function(data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum, index) {
        url = updateQueryStringParameter(baseURI, "_sql", datum.id);
        return (
          <tr key={`host-${datum.id}`}>
            <td className="ellipsis" key={`host-${datum.id}-0`}>
              <a href={url}>{datum.statement}</a>
            </td>
            <td width="100" key={`host-${datum.id}-2`}>{datum.freq}</td>
            <td width="100" key={`host-${datum.id}-3`}>{datum.avg.toFixed(2)}</td>
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

DatabaseDataPanel.defaultProps = {
  title: "Database",
  headers: [
    "Statement",
    "Freq",
    "Avg"
  ]
};
