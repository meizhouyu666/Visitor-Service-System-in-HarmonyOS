import { http } from '@kit.NetworkKit'
import { ApiResponse } from '../model/ApiModels'

// Team default for emulator -> host machine.
// For physical device testing, use developer's LAN IP locally (do not commit personal IPs).
const API_BASE_URL: string = 'http://10.0.2.2:8080'
type RequestPayload = Record<string, Object> | string | number | boolean | null

export class ApiClient {
  private token: string = ''

  setToken(token: string): void {
    this.token = token
  }

  async get<T>(path: string): Promise<T> {
    return this.request<T>(path, http.RequestMethod.GET)
  }

  async post<T, R>(path: string, payload: T): Promise<R> {
    return this.request<R>(path, http.RequestMethod.POST, payload)
  }

  async put<T, R>(path: string, payload: T): Promise<R> {
    return this.request<R>(path, http.RequestMethod.PUT, payload)
  }

  async delete<R>(path: string): Promise<R> {
    return this.request<R>(path, http.RequestMethod.DELETE)
  }

  private async request<R>(path: string, method: http.RequestMethod, payload?: RequestPayload): Promise<R> {
    const httpRequest: http.HttpRequest = http.createHttp()
    try {
      const response: http.HttpResponse = await httpRequest.request(
        `${API_BASE_URL}${path}`,
        {
          method,
          header: this.buildHeaders(),
          extraData: payload === undefined ? undefined : JSON.stringify(payload),
          expectDataType: http.HttpDataType.STRING
        }
      )

      const raw: string = `${response.result}`
      const body: ApiResponse<R> = JSON.parse(raw)
      if (body.code !== 0) {
        throw new Error(body.message)
      }
      return body.data
    } catch (error) {
      const message: string = `${error}`
      throw new Error(`Network request failed: ${message}`)
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
