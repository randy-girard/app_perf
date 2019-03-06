import React from "react"

class DataPanelBody extends React.Component {
  goToPage (e) {
    this.props.router.push('/some/location');
  }

  render () {
    return (
      <div className="box-body">
        <table className="table table-condensed">
          <thead>
            <tr>
              {this.props.headers.map(function(header) {
                return (
                  <th key={header}>{header}</th>
                )
              })}
            </tr>
          </thead>
          <tbody>
            {this.props.children}
          </tbody>
        </table>
      </div>
    )
  }
}
export default DataPanelBody
