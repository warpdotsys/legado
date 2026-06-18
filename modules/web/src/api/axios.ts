import axios from 'axios'

/** @type {string} localStorage保存自定义阅读http服务接口的键值 */
export const baseURL_localStorage_key = 'remoteUrl'
const SECOND = 1000

const getDefaultBaseURL = () => {
  if (import.meta.env.VITE_API) return import.meta.env.VITE_API
  
  const savedUrl = localStorage.getItem(baseURL_localStorage_key)
  if (savedUrl) return savedUrl
  
  // Custom Web Adapter: If served on port 4080, route by default to port 4081 proxy
  if (window.location && window.location.port === '4080') {
    return `${window.location.protocol}//${window.location.hostname}:4081`
  }
  
  return window.location.origin
}

const ajax = axios.create({
  baseURL: getDefaultBaseURL(),
  timeout: 120 * SECOND,
})

export default ajax

