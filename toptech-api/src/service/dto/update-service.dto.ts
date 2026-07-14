import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateServiceDto {
  @IsString()
  @IsNotEmpty()
  serviceName: string;
}
