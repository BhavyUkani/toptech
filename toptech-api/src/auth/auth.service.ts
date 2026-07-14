import { Injectable, UnauthorizedException } from '@nestjs/common';
import { EmployeeService } from '../employee/employee.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly employeeService: EmployeeService,
    private readonly jwtService: JwtService,
  ) {}

  async validateEmployee(identifier: string, pass: string): Promise<any> {
    const employee = await this.employeeService.findByIdentifier(identifier);
    if (employee && await bcrypt.compare(pass, employee.password)) {
      const result = employee.toJSON() as any;
      delete result.password;
      return result;
    }
    return null;
  }

  async login(employee: any) {
    const payload = { 
      username: employee.username, 
      sub: employee.id,
      email: employee.email,
    };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
