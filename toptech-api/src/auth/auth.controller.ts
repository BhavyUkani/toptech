import { Controller, Post, Get, Body, Req, UseGuards, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { EmployeeService } from '../employee/employee.service';
import { EmployeeDevice } from '../employee-device/employee-device.model';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly employeeService: EmployeeService,
    @InjectModel(EmployeeDevice)
    private readonly employeeDeviceModel: typeof EmployeeDevice,
  ) {}

  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    const employee = await this.authService.validateEmployee(
      loginDto.identifier,
      loginDto.password,
    );
    if (!employee) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(employee);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getProfile(@Req() req) {
    return this.employeeService.findOne(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('profile/onesignal')
  async updateOneSignalId(
    @Req() req,
    @Body('onesignalPlayerId') onesignalPlayerId: string,
  ) {
    if (!onesignalPlayerId) return { success: false, message: 'No player ID provided' };

    // Upsert: register this device for the user, or update timestamp if already exists
    await this.employeeDeviceModel.upsert({
      employeeId: req.user.id,
      onesignalPlayerId,
    } as any);

    console.log(`[OneSignal] Device registered — employeeId=${req.user.id} playerId=${onesignalPlayerId}`);
    return { success: true };
  }
}
