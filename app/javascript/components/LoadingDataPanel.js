import React from "react"

class LoadingDataPanel extends React.Component {
  render () {
    return (
      <div className='overlay'>
        <i className='fa fa-spinner fa-spin'></i>
      </div>
    )
  }
}
export default LoadingDataPanel
