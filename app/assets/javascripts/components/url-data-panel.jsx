window.UrlDataPanel = React.createClass({
  renderData: function(data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum, index) {
        domain = updateQueryStringParameter(baseURI, "_domain", datum.domain);
        url = updateQueryStringParameter(baseURI, "_url", datum.url);

        return (
          <tr key={`url-${index}`}>
            <td width="30%" className="ellipsis" key={`url-${index}-0`}>
              <a href={domain}>{datum.domain}</a>
            </td>
            <td className="ellipsis" key={`url-${index}-1`}>
              <a href={url}>{datum.url}</a>
            </td>
            <td width="100" key={`url-${index}-2`}>{datum.freq}</td>
            <td width="100" key={`url-${index}-3`}>{parseFloat(datum.avg).toFixed(2)}</td>
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

UrlDataPanel.defaultProps = {
  title: "Urls",
  headers: [
    "Domain",
    "Url",
    "Freq",
    "Avg"
  ]
};
