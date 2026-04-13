import { http } from '@kit.NetworkKit'
import { ApiResponse } from '../model/ApiModels'

// Team default for emulator -> host machine.
// For physical device testing, use developer's LAN IP locally (do not commit personal IPs).
const API_BASE_URL: string = 'http://10.0.2.2:8080'

export class ApiClient {
  private token: string = ''

  setToken(token: string): void {
    this.token = token
  }

  async get<T>(path: string): Promise<T> {
    const httpRequest: http.HttpRequest = http.createHttp()
    try {
      const response: http.HttpResponse = await httpRequest.request(
        `${API_BASE_URL}${path}`,
        {
          method: http.RequestMethod.GET,
          header: this.buildHeaders(),
          expectDataType: http.HttpDataType.STRING
        }
      )
      const body: ApiResponse<T> = JSON.parse(response.result as string) as ApiResponse<T>
      return body.data
    } finally {
      httpRequest.destroy()
    }
  }

  async post<T, R>(path: string, payload: T): Promise<R> {
    const httpRequest: http.HttpRequest = http.createHttp()
    try {
      const response: http.HttpResponse = await httpRequest.request(
        `${API_BASE_URL}${path}`,
        {
          method: http.RequestMethod.POST,
          header: this.buildHeaders(),
          extraData: JSON.stringify(payload),
          expectDataType: http.HttpDataType.STRING
        }
      )
      const body: ApiResponse<R> = JSON.parse(response.result as string) as ApiResponse<R>
      return body.data
    } finally {
      httpRequest.destroy()
    }
  }

  private buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    if (this.token.length > 0) {
      headers['Authorization'] = `Bearer ${this.token}`
    }
    return headers
  }
}

export const apiClient: ApiClient = new ApiClient()
