import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { SequelizeModule } from '@nestjs/sequelize';
import { Employee } from './employee/employee.model';
import { EmployeeModule } from './employee/employee.module';
import { AuthModule } from './auth/auth.module';
import { Enquiry } from './enquiry/enquiry.model';
import { EnquiryModule } from './enquiry/enquiry.module';
import { Category } from './category/category.model';
import { CategoryModule } from './category/category.module';
import { Product } from './product/product.model';
import { ProductModule } from './product/product.module';
import { Service } from './service/service.model';
import { ServiceModule } from './service/service.module';
import { EmployeeDevice } from './employee-device/employee-device.model';
import { EmployeeDeviceModule } from './employee-device/employee-device.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';

import { FollowupStatus } from './enquiry/followup-status.model';

@Module({
  imports: [
    // Configure environment variables globally
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    // Configure Sequelize connection
    SequelizeModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        dialect: 'mysql',
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_NAME'),
        models: [Employee, Enquiry, Category, Product, Service, EmployeeDevice, FollowupStatus],
        autoLoadModels: true,
        synchronize: true,
        sync: {
          alter: true,
        },
      }),
    }),
    EmployeeModule,
    AuthModule,
    EnquiryModule,
    CategoryModule,
    ProductModule,
    ServiceModule,
    EmployeeDeviceModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
