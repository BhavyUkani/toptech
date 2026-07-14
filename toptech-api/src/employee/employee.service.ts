import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Employee } from './employee.model';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import * as bcrypt from 'bcrypt';
import { Op } from 'sequelize';

@Injectable()
export class EmployeeService {
  constructor(
    @InjectModel(Employee)
    private readonly employeeModel: typeof Employee,
  ) {}

  async create(createEmployeeDto: CreateEmployeeDto): Promise<Employee> {
    const { name, username, number, email, password } = createEmployeeDto;

    // Check for existing fields
    const existing = await this.employeeModel.findOne({
      where: {
        [Op.or]: [
          { username },
          { email },
          { number },
        ],
      },
    });

    if (existing) {
      if (existing.username === username) {
        throw new ConflictException('Username is already taken');
      }
      if (existing.email === email) {
        throw new ConflictException('Email is already registered');
      }
      if (existing.number === number) {
        throw new ConflictException('Phone number is already registered');
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const employee = await this.employeeModel.create({
      name,
      username,
      number,
      email,
      password: hashedPassword,
    } as any);

    const result = employee.toJSON() as any;
    delete result.password;
    return result;
  }

  async findAll(): Promise<Employee[]> {
    return this.employeeModel.findAll({
      attributes: { exclude: ['password'] },
    });
  }

  async findOne(id: number): Promise<Employee> {
    const employee = await this.employeeModel.findByPk(id, {
      attributes: { exclude: ['password'] },
    });
    if (!employee) {
      throw new NotFoundException(`Employee with ID ${id} not found`);
    }
    return employee;
  }

  async findByIdentifier(identifier: string): Promise<Employee | null> {
    return this.employeeModel.findOne({
      where: {
        [Op.or]: [
          { username: identifier },
          { email: identifier },
          { number: identifier },
        ],
      },
    });
  }

  async update(id: number, updateEmployeeDto: UpdateEmployeeDto): Promise<Employee> {
    const employee = await this.employeeModel.findByPk(id);
    if (!employee) {
      throw new NotFoundException(`Employee with ID ${id} not found`);
    }

    const { name, username, number, email, password, role } = updateEmployeeDto;

    // Check uniqueness conflicts for other employees
    if (username || email || number) {
      const conflictClause: any[] = [];
      if (username) conflictClause.push({ username });
      if (email) conflictClause.push({ email });
      if (number) conflictClause.push({ number });

      const existing = await this.employeeModel.findOne({
        where: {
          id: { [Op.ne]: id },
          [Op.or]: conflictClause,
        },
      });

      if (existing) {
        if (username && existing.username === username) {
          throw new ConflictException('Username is already taken');
        }
        if (email && existing.email === email) {
          throw new ConflictException('Email is already registered');
        }
        if (number && existing.number === number) {
          throw new ConflictException('Phone number is already registered');
        }
      }
    }

    const updateData: any = {};
    if (name !== undefined) updateData.name = name;
    if (username !== undefined) updateData.username = username;
    if (number !== undefined) updateData.number = number;
    if (email !== undefined) updateData.email = email;
    if (role !== undefined) updateData.role = role;
    if (password !== undefined) {
      updateData.password = await bcrypt.hash(password, 10);
    }

    await employee.update(updateData);

    // Fetch the updated employee excluding password
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    const employee = await this.employeeModel.findByPk(id);
    if (!employee) {
      throw new NotFoundException(`Employee with ID ${id} not found`);
    }
    await employee.destroy();
  }
}
