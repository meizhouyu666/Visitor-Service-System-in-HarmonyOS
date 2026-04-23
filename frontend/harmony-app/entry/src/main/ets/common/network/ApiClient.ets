import { http } from '@kit.NetworkKit'
import { ApiResponse } from '../model/ApiModels'

// 团队默认地址：模拟器访问宿主机后端
// 真机联调时可本地改为局域网地址，但不要提交个人 IP
const API_BASE_URL: string = 'http://10.0.2.2:8081'

type RequestPayload = object

export class ApiClient {
  private token: string = ''

  setToken(token: string): void {
    this.token = token
  }

  async get<T>(path: string): Promise<T> {0
    return this.request<T>(path, http.RequestMethod.GET)
  }

  async post<T extends RequestPayload, R>(path: string, payload: T): Promise<R> {
    return this.request<R, T>(path, http.RequestMethod.POST, payload)
  }

  async put<T extends RequestPayload, R>(path: string, payload: T): Promise<R> {
    return this.request<R, T>(path, http.RequestMethod.PUT, payload)
  }

  async delete<R>(path: string): Promise<R> {
    return this.request<R>(path, http.RequestMethod.DELETE)
  }

  private async request<R, T extends RequestPayload | undefined = undefined>(
    path: string,
    method: http.RequestMethod,
    payload?: T
  ): Promise<R> {
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
      if (raw.trim().length === 0) {
        throw new Error('服务返回空响应')
      }
      const envelope: ApiResponse<R> = JSON.parse(raw)
      if (typeof envelope.code === 'number') {
        if (envelope.code !== 0) {
          throw new Error(envelope.message.length > 0 ? envelope.message : '请求失败，请稍后重试')
        }
        return envelope.data
      }
      const plain: R = JSON.parse(raw)
      return plain
    } catch (error) {
      if (error instanceof Error) {
        throw error
      }
      throw new Error('请求失败，请稍后重试')
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
